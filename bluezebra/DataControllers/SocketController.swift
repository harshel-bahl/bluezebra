//
//  SocketController.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 30/01/2023.
//

import Foundation
import SocketIO

class SocketController: NSObject, ObservableObject {
    
    static let shared = SocketController()
    
    var socketManager: SocketManager!
    var clientSocket: SocketIOClient!
    
    var ipAddress: String? = nil
    
    @Published var connected = false {
        didSet {
            log.info(message: "socket connected", info: "SocketController.connected: \(connected)")
        }
    }
    
    override init() {
        super.init()
        //        self.ipAddress = "24.199.84.35"
        
        self.socketManager = SocketManager(socketURL: URL(string: "http://\(ipAddress ?? "localhost"):3000")!,
                                           config: [
                                            .log(false),
                                            .compress,
                                            .forceNew(true),
                                            .reconnectAttempts(10),
                                            .reconnectWait(6000),
                                            .forceWebsockets(true),
                                           ])
        
        self.clientSocket = socketManager.defaultSocket
        
        self.createConnectionHandlers()
    }
    
    func createConnectionHandlers() {
        
        clientSocket.on(clientEvent: .connect) { [weak self] data, ack in
            
            guard let self = self else { return }
            
            self.connected = true
            
            Task {
                do {
                    try await UserDC.shared.connectUser()
                } catch {
                    
                }
            }
        }
        
        clientSocket.on(clientEvent: .disconnect) { [weak self] data, ack in
            
            guard let self = self else { return }
            
            self.connected = false
        }
        
        clientSocket.on(clientEvent: .error) { [weak self] data, ack in
            
            log.error(message: "socket connection errored", info: "clientSocket.on(clientEvent: .error), err: \((data[0] as? String) ?? "-")")
            
            guard let self = self else { return }
            
            self.connected = false
        }
        
    }
    
    func establishConnection(updateConnectParams: Bool = true) {
        
        if updateConnectParams {
            var connectParams: [String: Any] = [:]
            
            // add token param
            
            if !connectParams.isEmpty {
                self.socketManager.config.insert(.connectParams(connectParams))
            }
        }
        
        clientSocket.connect()
    }
    
    func closeConnection() {
        clientSocket.disconnect()
    }
    
    func resetSocket() {
        clientSocket.removeAllHandlers()
    }
}
