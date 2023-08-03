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
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- UserDC.checkUsername: FAILED (disconnected)")
            throw DCError.disconnected
        }
        
        let result = try await withCheckedThrowingContinuation() { continuation in
            SocketController.shared.clientSocket.emitWithAck("checkUsername", username)
                .timingOut(after: 1) { data in
                    do {
                        if let queryStatus = data.first as? String,
                           queryStatus == SocketAckStatus.noAck {
                            throw DCError.timeOut
                        } else if let queryStatus = data.first as? String {
                            throw DCError.serverError(message: queryStatus)
                        } else if let _ = data.first as? NSNull,
                                  data.indices.contains(1),
                                  let result = data[1] as? Bool {
                            print("SERVER \(DateU.shared.logTS) -- UserDC.checkUsername: SUCCESS (username: \(username), result: \(result))")
                            continuation.resume(returning: result)
                        } else {
                            throw DCError.failed
                        }
                    } catch {
                        print("SERVER \(DateU.shared.logTS) -- UserDC.checkUsername: FAILED \(error)")
                        continuation.resume(throwing: error)
                    }
                }
        }
        
        return result
    }
    
    func createUser(userID: String = UUID().uuidString,
                    username: String,
                    pin: String,
                    avatar: String,
                    creationDate: Date = DateU.shared.currDT) async throws -> (SUser, SSettings, SChannel) {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- UserDC.createUser: FAILED (disconnected)")
            throw DCError.disconnected
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
                                throw DCError.timeOut
                            } else if let queryStatus = data.first as? String {
                                throw DCError.serverError(message: queryStatus)
                            } else if let _ = data.first as? NSNull {
                                print("SERVER \(DateU.shared.logTS) -- UserDC.createUser: SUCCESS (username: \(username))")
                                continuation.resume(returning: ())
                            } else {
                                throw DCError.failed
                            }
                        } catch {
                            print("SERVER \(DateU.shared.logTS) -- UserDC.createUser: FAILED \(error)")
                            continuation.resume(throwing: error)
                        }
                    }
            }
            
            return (userData, userSettings, personalChannel)
        } catch {
            try? await DataPC.shared.fetchDeleteMOAsync(entity: User.self)
            try? await DataPC.shared.fetchDeleteMOAsync(entity: Settings.self)
            try? await DataPC.shared.fetchDeleteMOsAsync(entity: Channel.self,
                                                        predicateProperty: "channelID",
                                                        predicateValue: "personal")
            throw error
        }
    }
    
    func deleteUser() async throws {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- UserDC.deleteUser: FAILED (disconnected)")
            throw DCError.disconnected
        }
        
        let RUIDs = ChannelDC.shared.RUs.values.map {
            return $0.userID
        }
        
        guard let userID = self.userData?.userID else {
            throw DCError.nilError
        }
        
        let packet = try DataU.shared.jsonEncode(data: userID)
        
        try await withCheckedThrowingContinuation() { continuation in
            
            SocketController.shared.clientSocket.emitWithAck("deleteUser", ["userID": userID,
                                                                            "RUIDs": RUIDs,
                                                                            "packet": packet])
            .timingOut(after: 1) { data in
                do {
                    if let queryStatus = data.first as? String,
                       queryStatus == SocketAckStatus.noAck {
                        throw DCError.timeOut
                    } else if let queryStatus = data.first as? String {
                        throw DCError.serverError(message: queryStatus)
                    } else if let _ = data.first as? NSNull {
                        print("SERVER \(DateU.shared.logTS) -- UserDC.deleteUser: SUCCESS")
                        continuation.resume(returning: ())
                    } else {
                        throw DCError.failed
                    }
                } catch {
                    print("SERVER \(DateU.shared.logTS) -- UserDC.deleteUser: FAILED \(error)")
                    continuation.resume(throwing: error)
                }
            }
        }
        
        try await self.hardReset()
    }
    
    func connectUser() async throws {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- UserDC.connectUser: FAILED (disconnected)")
            throw DCError.disconnected
        }
        
        guard let userID = self.userData?.userID else { throw DCError.nilError }
        
        let RUIDs = ChannelDC.shared.channels.map {
            return $0.userID
        }
        
        try await withCheckedThrowingContinuation() { continuation in
            SocketController.shared.clientSocket.emitWithAck("connectUser", ["userID": userID,
                                                                             "RUIDs": RUIDs])
            .timingOut(after: 1, callback: { data in
                do {
                    if let queryStatus = data.first as? String,
                       queryStatus == SocketAckStatus.noAck {
                        throw DCError.timeOut
                    } else if let queryStatus = data.first as? String {
                        throw DCError.serverError(message: queryStatus)
                    } else if let _ = data.first as? NSNull {
                        print("SERVER \(DateU.shared.logTS) -- UserDC.connectUser: SUCCESS")
                        continuation.resume(returning: ())
                    } else {
                        throw DCError.failed
                    }
                } catch {
                    print("SERVER \(DateU.shared.logTS) -- UserDC.connectUser: FAILED \(error)")
                    continuation.resume(throwing: error)
                }
            })
        }
        
        DispatchQueue.main.async {
            self.userOnline = true
        }
    }
    
    func disconnectUser() async throws {
        
        let date = DateU.shared.currDT
        let dateString = DateU.shared.stringFromDate(date, TimeZone(identifier: "UTC")!)
        
        guard let userID = self.userData?.userID else { throw DCError.nilError }
        
        let SMO = try await DataPC.shared.updateMO(entity: User.self,
                                                           property: ["lastOnline"],
                                                           value: [date])
        DispatchQueue.main.async {
            self.userData = SMO
        }
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- UserDC.disconnectUser: FAILED (disconnected)")
            throw DCError.disconnected
        }
        
        let RUIDs = ChannelDC.shared.channels.map {
            return $0.userID
        }
        
        SocketController.shared.clientSocket.emit("disconnectUser", ["userID": userID,
                                                                     "RUIDs": RUIDs,
                                                                     "lastOnline": dateString])
    }
}
