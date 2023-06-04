//
//  UserDC+Events.swift
//  bluezebra
//
//  Created by Harshel Bahl on 19/04/2023.
//

import Foundation
import SocketIO

extension UserDC {
    
    /// Server-Local Functions
    ///
    func checkUsername(username: String,
                       completion: @escaping (Result<Bool, DCError>)->()) {
        guard SocketController.shared.connected else {
            print("SERVER \(Date.now) -- ChannelDC.checkUsername: FAILED (disconnected)")
            completion(.failure(.disconnected))
            return
        }
        
        SocketController.shared.clientSocket.emitWithAck("checkUsername", username)
            .timingOut(after: 1) { [weak self] data in
                guard let self = self else { return }
                
                self.socketCallback(data: data,
                                    functionName: "checkUsername",
                                    failureCompletion: completion) { data in
                    guard let data = data as? Bool else {
                        completion(.failure(.typecastError))
                        return
                    }
                    
                    completion(.success(data))
                }
            }
    }
    
    func createUser(username: String,
                    pin: String,
                    avatar: String,
                    completion: @escaping (Result<SUser, DCError>)->()) {
        
        guard SocketController.shared.connected else {
            print("SERVER \(Date.now) -- UserDC.createUser: FAILED (disconnected)")
            completion(.failure(.disconnected))
            return
        }
        
        let date = self.date
        guard let dateString = self.stringFromDate(date) else { return }
        
        let userPacket = UserPacket(username: username.trimmingCharacters(in: .whitespacesAndNewlines),
                                    avatar: avatar,
                                    creationDate: dateString)
        
        guard let packet = self.jsonEncode(userPacket) else { return }
        
        SocketController.shared.clientSocket.emitWithAck("createUser", ["packet": packet])
            .timingOut(after: 1, callback: { [weak self] data in
                guard let self = self else { return }
                
                self.socketCallback(data: data,
                                    functionName: "createUser",
                                    failureCompletion: completion) { _ in
                    
                    DataPC.shared.createUser(userID: userPacket.userID,
                                             username: userPacket.username,
                                             creationDate: date,
                                             pin: pin,
                                             avatar: userPacket.avatar) { result in
                        switch result {
                        case .success(let userData):
                            DataPC.shared.createSettings(biometricSetup: false) { result in
                                switch result {
                                case .success(let userSettings):
                                    DispatchQueue.main.async {
                                        self.userSettings = userSettings
                                        completion(.success(userData))
                                    }
                                case .failure(_): break
                                }
                            }
                            
                            Task {
                                let personalChannel = try? await DataPC.shared.createChannel(channelID: "personal",
                                                                                             active: true,
                                                                                             channelType: "personal",
                                                                                             userID: userPacket.userID,
                                                                                             creationUserID: userPacket.userID,
                                                                                             creationDate: date)
                                DispatchQueue.main.async {
                                    ChannelDC.shared.personalChannel = personalChannel
                                }
                            }
                        case .failure(_):
                            completion(.failure(.failed))
                        }
                    }
                }
            })
    }
    
    /// deleteUser
    /// "hard" represents deletion of all data on user-side, and all user-trace on remote users-side
    func deleteUser(completion: @escaping (Result<Void, DCError>)->()) {
        
        guard SocketController.shared.connected else {
            print("SERVER \(Date.now) -- UserDC.deleteUser: FAILED (disconnected)")
            completion(.failure(.disconnected))
            return
        }
        
        // send deleteUserTrace notifications to all remote users connected to user
        let remoteUserIDs = ChannelDC.shared.remoteUsers.values.map {
            return $0.userID
        }
        
        guard let userID = self.userData?.userID else { return }
        
        SocketController.shared.clientSocket.emitWithAck("deleteUser", ["userIDs": remoteUserIDs,
                                                                        "userID": userID])
        .timingOut(after: 1) { [weak self] data in
            guard let self = self else { return }
            
            self.socketCallback(data: data,
                                functionName: "deleteUser",
                                failureCompletion: completion) { _ in
                
                self.hardReset() { result in
                    switch result {
                    case .success():
                        completion(.success(()))
                    case .failure(_):
                        completion(.failure(.failed))
                    }
                }
            }
        }
    }
    
    
    func connectUser(completion: @escaping (Result<Void, DCError>)->()) {
        
        guard SocketController.shared.connected else {
            print("SERVER \(Date.now) -- UserDC.connectUser: FAILED (disconnected)")
            completion(.failure(.disconnected))
            return
        }
        
        guard let userID = self.userData?.userID else { return }
        
        let userIDs = ChannelDC.shared.userChannels.map {
            return $0.userID
        }
        
        SocketController.shared.clientSocket.emitWithAck("connectUser", ["userIDs": userIDs,
                                                                         "userID": userID])
        .timingOut(after: 1, callback: { [weak self] data in
            DispatchQueue.main.async {
                do {
                    if (data.first as? Bool)==true {
                        print("SERVER \(Date.now) -- UserDC.connectUser: SUCCESS")
                        self?.userOnline = true
                        completion(.success(()))
                    } else if (data.first as? Bool)==false {
                        throw DCError.serverFailure
                    } else if let result = data.first as? String, result==SocketAckStatus.noAck {
                        throw DCError.timeOut
                    } else {
                        throw DCError.failed
                    }
                } catch {
                    print("SERVER \(Date.now) -- UserDC.connectUser: FAILED (\(error))")
                    completion(.failure(error as? DCError ?? .failed))
                }
            }
        })
    }
    
    func disconnectUser() async {
        
        let date = self.date
        let dateString = self.dateString
        
        guard let userData = self.userData else { return }
        let userID = userData.userID
        
        guard let sUser = try? await DataPC.shared.updateMO(entity: User.self,
                                                            property: ["lastOnline"],
                                                            value: [date]) else { return }
        DispatchQueue.main.async {
            self.userData = sUser
        }
        
        guard SocketController.shared.connected else {
            print("SERVER \(Date.now) -- UserDC.disconnectUser: FAILED (disconnected)")
            return
        }
        
        let userIDs = ChannelDC.shared.userChannels.map {
            return $0.userID
        }
        
        SocketController.shared.clientSocket.emit("disconnectUser", ["userIDs": userIDs,
                                                                     "userID": userID,
                                                                     "lastOnline": dateString])
    }
}
