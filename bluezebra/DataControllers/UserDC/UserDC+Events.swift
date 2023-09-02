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
    /// 
    func checkUsername(username: String) async throws -> Bool {
        do {
            try checkSocketConnected()
            
            let result = try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("checkUsername", ["username": username] as [String: Any])
                    .timingOut(after: 1) { data in
                        do {
                            if let queryStatus = data.first as? String,
                               queryStatus == SocketAckStatus.noAck {
                                throw DCError.serverTimeOut()
                            } else if let queryStatus = data.first as? String {
                                throw DCError.serverFailure(err: queryStatus)
                            } else if let _ = data.first as? NSNull,
                                      data.indices.contains(1),
                                      let result = data[1] as? Bool {
                                continuation.resume(returning: result)
                            } else {
                                throw DCError.serverFailure()
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
            }
            
            log.debug(message: "successfully checked username", function: "UserDC.checkUsername", event: "checkUsername")
            
            return result
            
        } catch {
            log.error(message: "failed to check username", function: "UserDC.checkUsername", event: "checkUsername", error: error, info: "username: \(username)")
            throw error
        }
    }
    
    /// createUser
    ///
    func createUser(username: String,
                    pin: String,
                    avatar: String) async throws -> (SUser, SSettings, SChannel) {
        do {
            try checkSocketConnected()
            
            let (userdata, password, publicKey, userSettings, personalChannel) = try await self.createUserLocally(username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                                                                                             pin: pin,
                                                                                             avatar: avatar)
            
            let packet = try DataU.shared.jsonEncode(data: UserPacket(UID: userdata.UID,
                                                                      username: userdata.username,
                                                                      password: password,
                                                                      publicKey: publicKey,
                                                                      avatar: userdata.avatar,
                                                                      creationDate: DateU.shared.stringFromDate(userdata.creationDate, TimeZone(identifier: "UTC")!)))
            
            try await withCheckedThrowingContinuation { continuation in
                SocketController.shared.clientSocket.emitWithAck("createUser", ["packet": packet])
                    .timingOut(after: 1) { data in
                        do {
                            if let queryStatus = data.first as? String,
                               queryStatus == SocketAckStatus.noAck {
                                throw DCError.serverTimeOut()
                            } else if let queryStatus = data.first as? String {
                                throw DCError.serverFailure(err: queryStatus)
                            } else if let _ = data.first as? NSNull {
                                continuation.resume(returning: ())
                            } else {
                                throw DCError.serverFailure()
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
            }
            
            log.debug(message: "successfully created user", function: "UserDC.createUser", event: "createUser", info: "UID: \(userdata.UID)")
            
            return (userdata, userSettings, personalChannel)
        } catch {
            log.error(message: "failed to create user", function: "UserDC.createUser", event: "createUser", error: error)
            
            try? await self.deleteUserLocally()
            
            throw error
        }
    }
    
    /// deleteUser
    ///
    func deleteUser() async throws {
        do {
            try checkSocketConnected()
            
            try checkUserConnected()
            
            guard let UID = self.userdata?.UID else {
                throw DCError.nilError(err: "userdata is nil")
            }
            
            try await withCheckedThrowingContinuation() { continuation in
                
                SocketController.shared.clientSocket.emitWithAck("deleteUser", ["UID": UID] as [String : Any])
                    .timingOut(after: 1) { data in
                        do {
                            if let queryStatus = data.first as? String,
                               queryStatus == SocketAckStatus.noAck {
                                throw DCError.serverTimeOut()
                            } else if let queryStatus = data.first as? String {
                                throw DCError.serverFailure( err: queryStatus)
                            } else if let _ = data.first as? NSNull {
                                continuation.resume(returning: ())
                            } else {
                                throw DCError.serverFailure()
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    }
            }
            
            try await self.deleteUserLocally()
            
            log.debug(message: "successfully deleted user", function: "UserDC.deleteUser", event: "deleteUser")
        } catch {
            log.error(message: "failed to delete user", function: "UserDC.deleteUser", event: "deleteUser", error: error)
            throw error
        }
    }
    
    /// connectUser
    ///
    func connectUser() async throws {
        do {
            try checkSocketConnected()
            
            guard let UID = self.userdata?.UID else { throw DCError.nilError( err: "userdata is nil") }
            
            let password = try DataPC.shared.retrievePassword(account: "userPassword")
            
            try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("connectUser", ["UID": UID, "password": password] as [String : String])
                    .timingOut(after: 1, callback: { data in
                        do {
                            if let queryStatus = data.first as? String,
                               queryStatus == SocketAckStatus.noAck {
                                throw DCError.serverTimeOut()
                            } else if let queryStatus = data.first as? String,
                                      queryStatus == "user does not exist" {
                                
                                Task {
                                    try? await self.deleteUserLocally()
                                }
                                
                                throw DCError.serverFailure(err: "user does not exist")
                            } else if let queryStatus = data.first as? String {
                                throw DCError.serverFailure( err: queryStatus)
                            } else if let _ = data.first as? NSNull {
                                continuation.resume(returning: ())
                            } else {
                                throw DCError.serverFailure()
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    })
            }
            
            self.syncUserConnected(result: true)
            
            log.debug(message: "successfully connected user", function: "UserDC.connectUser", event: "connectUser")
        } catch {
            self.syncUserConnected(result: false)
            log.error(message: "failed to connect user", function: "UserDC.connectUser", event: "connectUser", error: error)
            throw error
        }
    }
}
