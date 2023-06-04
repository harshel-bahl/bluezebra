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
            print("CLIENT \(Date.now) -- SocketController.connected: \(connected)")
            if connected == true {
                self.userConnection()
            } else {
                
            }
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
            print("CLIENT \(Date.now) -- clientSocket.on(clientEvent): connected")
            
            guard let self = self else { return }
            self.connected = true
        }
        
        clientSocket.on(clientEvent: .disconnect) { [weak self] data, ack in
            print("CLIENT \(Date.now) -- clientSocket.on(clientEvent): disconnected")
            
            guard let self = self else { return }
            self.connected = false
            UserDC.shared.userOnline = false
        }
        
        clientSocket.on(clientEvent: .error) { data, ack in
            let errorString = (data[0] as? String)
            //print("socket error: \(errorString ?? "N/A")")
        }
    }
    
    func establishConnection() {
        clientSocket.connect()
    }

    func closeConnection() {
        clientSocket.disconnect()
    }
    
    func userConnection() {
        if self.connected && !UserDC.shared.userOnline && UserDC.shared.userData != nil {
            UserDC.shared.connectUser() {_ in
                self.startupNetworking()
            }
        }
    }
    
    func startupNetworking() {
        /// Startup Networking Activities
        Task {
            await ChannelDC.shared.checkOnlineUsers() {_ in}
        }
    }
    
    func resetSocket() {
        clientSocket.removeAllHandlers()
    }
}
