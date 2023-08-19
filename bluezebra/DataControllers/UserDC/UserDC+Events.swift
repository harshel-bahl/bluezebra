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
        
        do {
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
            
#if DEBUG
            DataU.shared.handleSuccess(function: "UserDC.checkUsername", info: "username: \(username)")
#endif
            
            return result
        } catch {
#if DEBUG
            DataU.shared.handleFailure(function: "UserDC.checkUsername", err: error, info: "username: \(username)")
#endif
            
            throw error
        }
    }
    
    /// createUser
    /// Create operation
    /// - Creates 3 objects to ensure error-free operations before request is sent
    /// - Receives ack, if successful then objects remain
    /// - Receives ack, if server failure or timeOut then obejcts are removed and error logged
    func createUser(username: String,
                    pin: String,
                    avatar: String) async throws -> (SUser, SSettings, SChannel) {
        
        do {
            guard SocketController.shared.connected else {
                throw DCError.serverDisconnected(func: "UserDC.createUser")
            }
            
            let (userData, userSettings, personalChannel) = try await self.createUserLocally(username: username.trimmingCharacters(in: .whitespacesAndNewlines),
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
            
#if DEBUG
            DataU.shared.handleSuccess(function: "UserDC.createUser", info: "username: \(username)")
#endif
            
            return (userData, userSettings, personalChannel)
        } catch {
            try? await self.deleteUserLocally()
            
#if DEBUG
            DataU.shared.handleFailure(function: "UserDC.createUser", err: error, info: "username: \(username)")
#endif
            
            throw error
        }
    }
    
    /// deleteUser
    /// Delete Operation
    /// - Sends request to server
    /// - On successful ack, local delete operations will occur
    /// - On failure or timeOut, nothing happens
    func deleteUser() async throws {
        
        do {
            guard SocketController.shared.connected else {
                throw DCError.serverDisconnected(func: "UserDC.deleteUser")
            }
            
            guard UserDC.shared.userOnline else {
                throw DCError.userDisconnected(func: "UserDC.deleteUser")
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
            
#if DEBUG
            DataU.shared.handleSuccess(function: "UserDC.deleteUser")
#endif
        } catch {
#if DEBUG
            DataU.shared.handleFailure(function: "UserDC.deleteUser", err: error)
#endif
            
            throw error
        }
    }
    
    /// connectUser
    ///
    func connectUser() async throws {
        
        do {
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
                                      queryStatus == "event: connectUser, info: user does not exist" {
                                
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
            
#if DEBUG
            DataU.shared.handleSuccess(function: "UserDC.connectUser")
#endif
        } catch {
#if DEBUG
            DataU.shared.handleFailure(function: "UserDC.connectUser", err: error)
#endif
            
            throw error
        }
    }
}
