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
    func createUser(username: String,
                    pin: String,
                    avatar: String) async throws -> (SUser, SSettings, SChannel) {
        
        guard SocketController.shared.connected else {
            throw DCError.serverDisconnected(func: "UserDC.createUser")
        }
        
        do {
            let (userData, userSettings, personalChannel) = try await self.createUser(username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                                                                                      pin: pin,
                                                                                      avatar: avatar)
            
            let packet = try DataU.shared.jsonEncode(data: UserPacket(userID: userData.userID,
                                                                      username: userData.username,
                                                                      avatar: userData.avatar,
                                                                      creationDate: DateU.shared.stringFromDate(userData.creationDate, TimeZone(identifier: "UTC")!)))
            
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
            try? await self.deleteUserLocally()
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
        
        guard let userID = self.userData?.userID else {
            throw DCError.nilError(func: "UserDC.deleteUser", err: "userData is nil")
        }
        
        try await withCheckedThrowingContinuation() { continuation in
            
            SocketController.shared.clientSocket.emitWithAck("deleteUser", ["userID": userID] as [String : Any])
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
        
        try await self.deleteUserLocally()
    }
    
    /// connectUser
    /// 
    func connectUser() async throws {
        
        guard SocketController.shared.connected else {
            throw DCError.serverDisconnected(func: "UserDC.connectUser")
        }
        
        guard let userID = self.userData?.userID else { throw DCError.nilError(func: "connectUser", err: "userData is nil") }
        
        try await withCheckedThrowingContinuation() { continuation in
            SocketController.shared.clientSocket.emitWithAck("connectUser", ["userID": userID] as [String : Any])
            .timingOut(after: 1, callback: { data in
                do {
                    if let queryStatus = data.first as? String,
                       queryStatus == SocketAckStatus.noAck {
                        throw DCError.serverTimeOut(func: "UserDC.connectUser")
                    } else if let queryStatus = data.first as? String,
                              queryStatus == "user does not exist" {
                        
                        Task {
                            try? await self.deleteUserLocally()
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
        
        SocketController.shared.clientSocket.emit("disconnectUser", ["userID": userID])
    }
}
