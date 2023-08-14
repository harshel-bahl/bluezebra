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
#if DEBUG
            DataU.shared.handleSuccess(info: "SocketController.connected: \(connected)")
#endif
        }
    }
    
    override init() {
        super.init()
        //        self.ipAddress = "24.199.84.35"
        self.socketManager = SocketManager(socketURL: URL(string: "http://\(ipAddress ?? "localhost"):3000")!, config: [.log(false), .compress])
        self.clientSocket = socketManager.defaultSocket
        self.createConnectionHandlers()
    }
    
    func createConnectionHandlers() {
        clientSocket.on(clientEvent: .connect) { [weak self] data, ack in
#if DEBUG
            DataU.shared.handleSuccess(info: "clientSocket.on(clientEvent: .connect)")
#endif
            
            guard let self = self else { return }
            
            self.connected = true
        }
        
        clientSocket.on(clientEvent: .disconnect) { [weak self] data, ack in
#if DEBUG
            DataU.shared.handleSuccess(info: "clientSocket.on(clientEvent: .disconnect)")
#endif
            
            guard let self = self else { return }
            
            self.connected = false
        }
        
        clientSocket.on(clientEvent: .error) { data, ack in
#if DEBUG
            DataU.shared.handleFailure(info: "clientSocket.on(clientEvent: .error), err: \((data[0] as? String) ?? "-")")
#endif
        }
    }
    
    func establishConnection() {
        clientSocket.connect() // manager.socket.connect(withPayload: ["auth": "xxx"])
    }
    
    func closeConnection() {
        clientSocket.disconnect()
    }
    
    func resetSocket() {
        clientSocket.removeAllHandlers()
    }
}
