//
//  MessageDC+Events.swift
//  bluezebra
//
//  Created by Harshel Bahl on 22/04/2023.
//

import Foundation

extension MessageDC {
    
    /// Server-Local ChannelMessageFunctions
    ///
    func sendMessage(channel: SChannel,
                     remoteUserID: String,
                     message: String,
                     type: String,
                     completion: @escaping (Result<Void, DCError>)->()) {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.sendMessage: FAILED (disconnected)")
            completion(.failure(.disconnected))
            return
        }
        
        guard let userID = UserDC.shared.userData?.userID else { return }
        
        let messagePacket = MessagePacket(channelID: channel.channelID,
                                          userID: userID,
                                          type: type,
                                          date: DateU.shared.currSDT,
                                          message: message)
        
        guard let jsonPacket = try? DataU.shared.jsonEncode(messagePacket),
              let date = DateU.shared.dateFromString(messagePacket.date) else { return }
        
        SocketController.shared.clientSocket.emitWithAck("sendMessage", ["userID": remoteUserID,
                                                                         "packet": jsonPacket])
        .timingOut(after: 1) { [weak self] data in
            guard let self = self else { return }
            
            self.socketCallback(data: data,
                                functionName: "sendChannelMessage",
                                failureCompletion: completion) { data in
                Task {
                    do {
                        let message = try await DataPC.shared.createMessage(messageID: messagePacket.messageID,
                                                                            channelID: messagePacket.channelID,
                                                                            userID: messagePacket.userID,
                                                                            type: type,
                                                                            date: date,
                                                                            message: message,
                                                                            isSender: true,
                                                                            sent: [remoteUserID],
                                                                            delivered: [String](),
                                                                            read: [String](),
                                                                            remoteDeleted: [String]())
                        if self.userMessages.keys.contains(remoteUserID) {
                            self.userMessages[remoteUserID]?.insert(message, at: 0)
                        } else {
                            // fetch remote user messages
                        }
                        
                        completion(.success(()))
                    } catch {
                        completion(.failure(.failed))
                    }
                }
            }
        }
    }
    
    func sendDeliveredMessage(message: Message,
                              completion: ((Result<Void, DCError>)->())? = nil) {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- ChannelDataController.sendDeliveredMessage: FAILED (disconnected)")
            return
        }
        
        guard let messageID = message.messageID,
              let userID = message.userID else { return }
        
        SocketController.shared.clientSocket.emitWithAck("sendDeliveredMessage", ["userID": userID,
                                                                                  "messageID": messageID])
        .timingOut(after: 1) { [weak self] data in
            
            guard let self = self else { return }
            
            self.socketCallback(data: data,
                                functionName: "sendDeliveredMessage",
                                failureCompletion: completion) { _ in }
        }
    }
    
    func sendReadMessage(message: Message,
                         completion: ((Result<Void, DCError>)->())? = nil) {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- ChannelDataController.sendReadMessage: FAILED (disconnected)")
            return
        }
        
        guard let messageID = message.messageID,
              let userID = message.userID else { return }
        
        SocketController.shared.clientSocket.emitWithAck("sendReadMessage", ["userID": userID,
                                                                             "messageID": messageID])
        .timingOut(after: 1) { [weak self] data in
            
            guard let self = self else { return }
            
            self.socketCallback(data: data,
                                functionName: "sendReadMessage",
                                failureCompletion: completion) { _ in }
        }
    }
}


