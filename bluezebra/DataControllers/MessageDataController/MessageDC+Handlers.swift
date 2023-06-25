//
//  MessageDC+Handlers.swift
//  bluezebra
//
//  Created by Harshel Bahl on 22/04/2023.
//

import Foundation

extension MessageDC {
    
    /// Socket Handlers
    ///
    func addSocketHandlers() {
        self.receivedMessage()
        self.deliveredMessage()
        self.readMessage()
        self.receivedMessageDeletion()
        self.receivedMessageDeletionResult()
    }
    
    func deliveredMessage() {
        SocketController.shared.clientSocket.on("deliveredMessage") { [weak self] (data, ack) in
            print("SERVER -- deliveredMessage triggered")
            
        }
    }
    
    func readMessage() {
        SocketController.shared.clientSocket.on("readMessage") { [weak self] (data, ack) in
            print("SERVER -- readMessage triggered")
            
        }
    }
    
    func receivedMessage() {
        Task {
            self.readMessage()
        }
        SocketController.shared.clientSocket.on("receivedMessage") { [weak self] (data, ack) in
            print("SERVER -- receivedMessage triggered")
//            guard let dataPacket = self?.jsonDecodeFromData(packet: MessagePacket.self,
//                                                            data: data),
//                  let date = self!.dateFromString(dataPacket.date) else { return }
//            
//            DataPC.shared.createMessage(messageID: dataPacket.messageID,
//                                                           channelID: dataPacket.channelID,
//                                                           userID: dataPacket.userID,
//                                                           type: dataPacket.type,
//                                                           date: date,
//                                                           message: dataPacket.message,
//                                                           isSender: false,
//                                                           sent: [dataPacket.userID],
//                                                           delivered: [dataPacket.userID],
//                                                           read: [String]()) { result in
//                switch result {
//                case .success(let message):
//                    guard self!.channelMessages.keys.contains(dataPacket.channelID) else { return }
//                    
//                    self!.channelMessages[dataPacket.channelID]?.insert(message, at: 0)
//                    
//                    self?.sendDeliveredMessage(message: message)
//                case .failure(_): ack.with(false)
//                }
//            }
        }
    }

    func receivedMessageDeletion() {
        SocketController.shared.clientSocket.on("receivedMessageDeletion") { [weak self] (data, ack) in
            print("SERVER -- receivedMessageDeletion triggered")

        }
    }
    
    func receivedMessageDeletionResult() {
        SocketController.shared.clientSocket.on("receivedMessageDeletionResult") { [weak self] (data, ack) in
            print("SERVER -- receivedMessageDeletionResult triggered")

        }
    }
}
