//
//  UserDC+Events.swift
//  bluezebra
//
//  Created by Harshel Bahl on 19/04/2023.
//

import Foundation
import SocketIO

extension UserDC {
    
    /// checkUsername
    /// Request operation - sends request to server and waits for response
    func checkUsername(username: String) async throws -> Bool {
        
        guard SocketController.shared.connected else {
            throw DCError.serverDisconnected(func: "UserDC.checkUsername")
        }
        
        let result = try await withCheckedThrowingContinuation() { continuation in
            SocketController.shared.clientSocket.emitWithAck("checkUsername", username)
                .timingOut(after: 1) { data in
                    do {
                        if let queryStatus = data.first as? String,
                           queryStatus == SocketAckStatus.noAck {
                            throw DCError.serverTimeOut(func: "UserDC.checkUsername")
                        } else if let queryStatus = data.first as? String {
                            throw DCError.serverFailure(func: "UserDC.checkUsername", err: queryStatus)
                        } else if let _ = data.first as? NSNull,
                                  data.indices.contains(1),
                                  let result = data[1] as? Bool {
                            continuation.resume(returning: result)
                        } else {
                            throw DCError.serverFailure(func: "UserDC.checkUsername")
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
        }
        
        return result
    }
    
    /// createUser
    /// Create operation
    /// - Creates 3 objects to ensure error-free operations before request is sent
    /// - Receives ack, if successful then objects remain
    /// - Receives ack, if server failure or timeOut then obejcts are removed and error logged
    func createUser(userID: String = UUID().uuidString,
                    username: String,
                    pin: String,
                    avatar: String,
                    creationDate: Date = DateU.shared.currDT) async throws -> (SUser, SSettings, SChannel) {
        
        guard SocketController.shared.connected else {
            throw DCError.serverDisconnected(func: "UserDC.createUser")
        }
        
        do {
            let userData = try await DataPC.shared.createUser(userID: userID,
                                                              username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                                                              creationDate: creationDate,
                                                              avatar: avatar)
            
            let userSettings = try await DataPC.shared.createSettings(pin: pin)
            
            let personalChannel = try await DataPC.shared.createChannel(channelID: "personal",
                                                                        active: true,
                                                                        userID: userData.userID,
                                                                        creationDate: creationDate)
            
            let packet = try DataU.shared.jsonEncode(data: UserPacket(userID: userData.userID,
                                                                      username: userData.username,
                                                                      avatar: userData.avatar,
                                                                      creationDate: DateU.shared.stringFromDate(creationDate, TimeZone(identifier: "UTC")!)))
            
            try await withCheckedThrowingContinuation { continuation in
                
                SocketController.shared.clientSocket.emitWithAck("createUser", ["packet": packet])
                    .timingOut(after: 1) { data in
                        do {
                            if let queryStatus = data.first as? String,
                               queryStatus == SocketAckStatus.noAck {
                                throw DCError.serverTimeOut(func: "UserDC.createUser")
                            } else if let queryStatus = data.first as? String {
                                throw DCError.serverFailure(func: "UserDC.createUser", err: queryStatus)
                            } else if let _ = data.first as? NSNull {
                                continuation.resume(returning: ())
                            } else {
                                throw DCError.serverFailure(func: "UserDC.createUser")
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
            }
            
            return (userData, userSettings, personalChannel)
        } catch {
            try? await DataPC.shared.fetchDeleteMO(entity: User.self)
            try? await DataPC.shared.fetchDeleteMO(entity: Settings.self)
            try? await DataPC.shared.fetchDeleteMOs(entity: Channel.self,
                                                    predicateProperty: "channelID",
                                                    predicateValue: "personal")
            throw error
        }
    }
    
    /// deleteUser
    /// Delete Operation
    /// - Sends request to server
    /// - On successful ack, local delete operations will occur
    /// - On failure or timeOut, nothing happens
    func deleteUser() async throws {
        
        guard SocketController.shared.connected else {
            throw DCError.serverDisconnected(func: "UserDC.deleteUser")
        }
        
        let RUIDs = ChannelDC.shared.channels.map {
            return $0.userID
        }
        
        guard let userID = self.userData?.userID else {
            throw DCError.nilError(func: "UserDC.deleteUser", err: "userData is nil")
        }
        
        let packet = try DataU.shared.jsonEncode(data: userID)
        
        try await withCheckedThrowingContinuation() { continuation in
            
            SocketController.shared.clientSocket.emitWithAck("deleteUser", ["userID": userID,
                                                                            "RUIDs": RUIDs,
                                                                            "packet": packet] as [String : Any])
            .timingOut(after: 1) { data in
                do {
                    if let queryStatus = data.first as? String,
                       queryStatus == SocketAckStatus.noAck {
                        throw DCError.serverTimeOut(func: "UserDC.deleteUser")
                    } else if let queryStatus = data.first as? String {
                        throw DCError.serverFailure(func: "UserDC.deleteUser", err: queryStatus)
                    } else if let _ = data.first as? NSNull {
                        continuation.resume(returning: ())
                    } else {
                        throw DCError.serverFailure(func: "UserDC.deleteUser")
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
        
        try await self.hardReset()
    }
    
    /// connectUser
    /// 
    func connectUser() async throws {
        
        guard SocketController.shared.connected else {
            throw DCError.serverDisconnected(func: "UserDC.connectUser")
        }
        
        guard let userID = self.userData?.userID else { throw DCError.nilError(func: "connectUser", err: "userData is nil") }
        
        let RUIDs = ChannelDC.shared.channels.map {
            return $0.userID
        }
        
        try await withCheckedThrowingContinuation() { continuation in
            SocketController.shared.clientSocket.emitWithAck("connectUser", ["userID": userID,
                                                                             "RUIDs": RUIDs] as [String : Any])
            .timingOut(after: 1, callback: { data in
                do {
                    if let queryStatus = data.first as? String,
                       queryStatus == SocketAckStatus.noAck {
                        throw DCError.serverTimeOut(func: "UserDC.connectUser")
                    } else if let queryStatus = data.first as? String,
                              queryStatus == "user does not exist" {
                        
                        Task {
                            try? await self.hardReset()
                        }
                        
                        throw DCError.serverFailure(func: "UserDC.connectUser", err: "user does not exist")
                    } else if let queryStatus = data.first as? String {
                        throw DCError.serverFailure(func: "UserDC.connectUser", err: queryStatus)
                    } else if let _ = data.first as? NSNull {
                        continuation.resume(returning: ())
                    } else {
                        throw DCError.serverFailure(func: "UserDC.connectUser")
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            })
        }
        
        DispatchQueue.main.async {
            self.userOnline = true
        }
    }
    
    /// disconnectUser
    ///
    func disconnectUser(datetime: Date = DateU.shared.currDT) async throws {
        
        guard let userID = self.userData?.userID else { throw DCError.nilError(func: "UserDC.disconnectUser", err: "userData is nil") }
        
        let SMO = try await DataPC.shared.updateMO(entity: User.self,
                                                           property: ["lastOnline"],
                                                           value: [datetime])
        DispatchQueue.main.async {
            self.userData = SMO
        }
        
        guard SocketController.shared.connected else {
            throw DCError.serverDisconnected(func: "UserDC.disconnectUser")
        }
        
        let RUIDs = ChannelDC.shared.channels.map {
            return $0.userID
        }
        
        SocketController.shared.clientSocket.emit("disconnectUser", ["userID": userID,
                                                                     "RUIDs": RUIDs,
                                                                     "lastOnline": DateU.shared.stringFromDate(datetime, TimeZone(identifier: "UTC")!)] as [String : Any])
    }
}
