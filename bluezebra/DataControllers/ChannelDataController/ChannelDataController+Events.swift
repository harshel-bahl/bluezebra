//
//  ChannelDC+Events.swift
//  bluezebra
//
//  Created by Harshel Bahl on 19/04/2023.
//

import Foundation
import SocketIO

extension ChannelDC {
    
    /// Server Fetch Functions
    ///
    func fetchRemoteUser(userID: String?,
                         username: String?,
                         checkUsername: Bool = true,
                         completion: @escaping (Result<[RemoteUserPacket], DCError>)->()) {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.fetchRemoteUser: FAILED (disconnected)")
            completion(.failure(.disconnected))
            return
        }
        
        if checkUsername {
            guard username != UserDC.shared.userData?.username else { return }
        }
        
        SocketController.shared.clientSocket.emitWithAck("fetchUser", ["username": username])
            .timingOut(after: 1, callback: { [weak self] data in
                guard let self = self else { return }
                
                self.socketCallback(data: data,
                                    functionName: "fetchRemoteUser",
                                    failureCompletion: completion) { data in
                    guard let data = data,
                          let remoteUserPackets = try? self.jsonDecodeFromObject(packet: [RemoteUserPacket].self,
                                                                                 data: data) else { return }
                    completion(.success(remoteUserPackets))
                }
            })
    }

    
    /// Server-Local Channel Functions
    ///
    func checkOnlineUsers(completion: @escaping (Result<Void, DCError>)->()) async {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.checkOnlineUsers: FAILED (disconnected)")
            completion(.failure(.disconnected))
            return
        }
        
        var userIDs = [String]()
        for channel in self.userChannels {
            guard let userID = channel.userID else { return }
            userIDs.append(userID)
        }
        
        SocketController.shared.clientSocket.emitWithAck("checkOnlineUsers", ["userIDs": userIDs])
            .timingOut(after: 1, callback: { [weak self] data in
                guard let self = self else { return }
                
                self.socketCallback(data: data,
                                    functionName: "checkOnlineUsers",
                                    failureCompletion: completion) { data in
                    
                    guard let data = data as? NSDictionary else { return }
                    
                    for userID in data.allKeys {
                        guard let userID = userID as? String else { return }
                        
                        if let userOnline = data[userID] as? Bool {
                            self.onlineUsers[userID] = userOnline
                        } else if let lastOnline = data[userID] as? String {
                            self.onlineUsers[userID] = false
                            
                            guard let lastOnlineDate = DateU.shared.dateFromString(lastOnline) else { return }
                            
                            Task {
                                guard let remoteUser = try? await DataPC.shared.updateMO(entity: RemoteUser.self,
                                                                                         property: ["lastOnline"],
                                                                                         value: [lastOnlineDate]) else { return }
                                self.remoteUsers[userID] = remoteUser
                            }
                        }
                    }
                    completion(.success(()))
                }
            })
    }
    
    /// sendUserChannelRequest:
    /// handles creation of user channels and creates channel and remote user in inactive state
    func sendChannelRequest(RUPacket: RemoteUserPacket,
                            checkUserID: Bool = true,
                            completion: @escaping (Result<Void, DCError>)->()) {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.sendChannelRequest: FAILED (disconnected)")
            return
        }
        
        guard let originUser = UserDC.shared.userData else { return }
        
        if checkUserID {
            guard RUPacket.userID != UserDC.shared.userData?.userID else { return }
        }
        
        let CRPacket = ChannelRequestPacket(channel: ChannelPacket(channelType: "user",
                                                                   userID: originUser.userID,
                                                                   creationUserID: originUser.userID),
                                            remoteUser: RemoteUserPacket(userID: originUser.userID,
                                                                         username: originUser.username,
                                                                         avatar: originUser.avatar),
                                            date: DateU.shared.currSDT)
        
        guard let jsonPacket = try? DataU.shared.jsonEncode(CRPacket),
              let date = DateU.shared.dateFromString(CRPacket.date) else { return }
        
        SocketController.shared.clientSocket.emitWithAck("sendChannelRequest", ["userID": RUPacket.userID,
                                                                                "packet": jsonPacket])
        .timingOut(after: 1) { [weak self] data in
            guard let self = self else { return }
            
            self.socketCallback(data: data,
                                functionName: "sendChannelRequest",
                                failureCompletion: completion) { _ in
                Task {
                    do {
                        let channelRequest = try await DataPC.shared.createChannelRequest(channelID: CRPacket.channel.channelID,
                                                                                          userID: RUPacket.userID,
                                                                                          date: date,
                                                                                          isSender: true)
                        await self.fetchChannelRequests()
                        
                        let remoteUser = try? await DataPC.shared.createRemoteUser(userID: RUPacket.userID,
                                                                                   username: RUPacket.username,
                                                                                   avatar: RUPacket.avatar)
                        if remoteUser != nil { await self.fetchRemoteUsers() }
                        
                        let channel = try await DataPC.shared.createChannel(channelID: CRPacket.channel.channelID,
                                                                            channelType: CRPacket.channel.channelType,
                                                                            userID: RUPacket.userID,
                                                                            creationUserID: CRPacket.channel.creationUserID,
                                                                            creationDate: date,
                                                                            lastMessageDate: date)
                        await self.fetchUserChannels()
                    } catch {
                        completion(.failure(DCError.failed))
                    }
                }
            }
        }
    }
    
    
    /// sendChannelRequestResult:
    /// handles sending a user channel result
    func sendUserCRResult(channelRequest: SChannelRequest,
                                  result: Bool,
                                  completion: @escaping (Result<Void, DCError>)->()) {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.sendUserCRResult: FAILED (disconnected)")
            completion(.failure(.disconnected))
            return
        }
        
        guard let userID = channelRequest.userID else { return }
        let date = DateU.shared.currDT
        
        SocketController.shared.clientSocket.emitWithAck("sendChannelRequestResult", ["userID": userID,
                                                                                      "packet": ["channelID": channelRequest.channelID,
                                                                                                 "result": result]])
        .timingOut(after: 1) { [weak self] data in
            guard let self = self else { return }
            
            self.socketCallback(data: data,
                                functionName: "sendUserCRResult",
                                failureCompletion: completion) { _ in
                Task {
                    if (result==true) {
                        do {
                            try await DataPC.shared.fetchDeleteMOAsync(entity: ChannelRequest.self,
                                                                       predicateProperty: "channelID",
                                                                       predicateValue: channelRequest.channelID)
                            await self.fetchChannelRequests()
                            
                            let _ = try await DataPC.shared.updateMO(entity: Channel.self,
                                                                     property: ["active", "creationDate", "lastMessageDate"],
                                                                     value: [true, date, date])
                            await self.fetchUserChannels()
                        } catch {
                            completion(.failure(.failed))
                        }
                    } else if (result==false) {
                        do {
                            try await DataPC.shared.fetchDeleteMOAsync(entity: ChannelRequest.self,
                                                                       predicateProperty: "channelID",
                                                                       predicateValue: channelRequest.channelID)
                            await self.fetchChannelRequests()
                            
                            try await DataPC.shared.fetchDeleteMOAsync(entity: Channel.self,
                                                                       predicateProperty: "channelID",
                                                                       predicateValue: channelRequest.channelID)
                            
                            let RUCheck = try await self.checkRUInTeams(userID: userID)
                            
                            if !RUCheck {
                                try await DataPC.shared.fetchDeleteMOAsync(entity: RemoteUser.self,
                                                                           predicateProperty: "userID",
                                                                           predicateValue: channelRequest.userID)
                                await self.fetchRemoteUsers()
                            }
                        } catch {
                            completion(.failure(.failed))
                        }
                    }
                }
            }
        }
    }
    
    func deleteChannel(channel: SChannel,
                       remoteUser: SRemoteUser,
                       type: String = "clear",
                       completion: @escaping (Result<Void, DCError>)->()) {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.deleteChannel: FAILED (disconnected)")
            completion(.failure(.disconnected))
            return
        }
        
        let CDPacket = ChannelDeletionPacket(channelID: channel.channelID,
                                             channelType: channel.channelType,
                                             deletionDate: DateU.shared.currSDT,
                                             type: type)
        
        guard let jsonPacket = try? DataU.shared.jsonEncode(CDPacket),
              let userID = channel.userID,
              let deletionDate = DateU.shared.dateFromString(CDPacket.deletionDate) else { return }
        
        SocketController.shared.clientSocket.emitWithAck("sendChannelDeletion", ["userID": userID,
                                                                                 "packet": jsonPacket])
        .timingOut(after: 1, callback: { [weak self] data in
            guard let self = self else { return }
            
            self.socketCallback(data: data,
                                functionName: "deleteChannel",
                                failureCompletion: completion) { data in
                
                Task {
                    do {
                        let _ = try await DataPC.shared.createChannelDeletion(channelType: channel.channelType,
                                                                              deletionDate: deletionDate,
                                                                              type: type,
                                                                              name: remoteUser.username,
                                                                              icon: remoteUser.avatar,
                                                                              nUsers: 1,
                                                                              toDeleteUserIDs: [userID],
                                                                              isOrigin: true)
                        await self.fetchChannelDeletions()
                        
                        if type=="clear" {
                            // delete channel messages
                        } else if type=="delete" {
                            // delete channel messages
                            
                            try await DataPC.shared.fetchDeleteMOAsync(entity: Channel.self,
                                                                       predicateProperty: "channelID",
                                                                       predicateValue: channel.channelID)
                            await self.fetchUserChannels()
                            
                            let RUCheck = try await self.checkRUInTeams(userID: userID)
                            
                            if !RUCheck {
                                try await DataPC.shared.fetchDeleteMOAsync(entity: RemoteUser.self,
                                                                           predicateProperty: "userID",
                                                                           predicateValue: channel.userID)
                                await self.fetchRemoteUsers()
                            }
                        }
                    } catch {
                        completion(.failure(.failed))
                    }
                }
            }
        })
    }
}
