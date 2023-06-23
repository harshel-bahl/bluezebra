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
    func fetchRU(userID: String?,
                 checkUserID: Bool = true,
                 completion: @escaping (Result<[RUPacket], DCError>)->()) {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.fetchRU: FAILED (disconnected)")
            completion(.failure(.disconnected))
            return
        }
        
        if checkUserID {
            guard userID != UserDC.shared.userData?.userID else { return }
        }
        
        SocketController.shared.clientSocket.emitWithAck("fetchRU", ["userID": userID])
            .timingOut(after: 1, callback: { [weak self] data in
                guard let self = self else { return }
                
                self.socketCallback(data: data,
                                    functionName: "fetchRU",
                                    failureCompletion: completion) { data in
                    guard let data = data,
                          let RUPackets = try? self.jsonDecodeFromObject(packet: [RUPacket].self,
                                                                         data: data) else { return }
                    completion(.success(RUPackets))
                }
            })
    }
    
    func fetchRUs(username: String?,
                  checkUsername: Bool = true,
                  completion: @escaping (Result<[RUPacket], DCError>)->()) {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.fetchRUs: FAILED (disconnected)")
            completion(.failure(.disconnected))
            return
        }
        
        if checkUsername {
            guard username != UserDC.shared.userData?.username else { return }
        }
        
        SocketController.shared.clientSocket.emitWithAck("fetchRUs", ["username": username])
            .timingOut(after: 1, callback: { [weak self] data in
                guard let self = self else { return }
                
                self.socketCallback(data: data,
                                    functionName: "fetchRUs",
                                    failureCompletion: completion) { data in
                    guard let data = data,
                          let RUPackets = try? self.jsonDecodeFromObject(packet: [RUPacket].self,
                                                                         data: data) else { return }
                    completion(.success(RUPackets))
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
        for channel in self.channels {
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
                                self.RUs[userID] = remoteUser
                            }
                        }
                    }
                    completion(.success(()))
                }
            })
    }
    
    /// sendCR:
    /// 
    func sendCR(remoteUser: RUPacket,
                checkUserID: Bool = true,
                completion: @escaping (Result<Void, DCError>)->()) {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.sendCR: FAILED (disconnected)")
            return
        }
        
        guard let originUser = UserDC.shared.userData else { return }
        let creationDate = DateU.shared.stringFromDate(originUser.creationDate, TimeZone(identifier: "UTC")!)
        
        if checkUserID {
            guard remoteUser.userID != UserDC.shared.userData?.userID else { return }
        }
        
        let CRPacket = CRPacket(channel: ChannelPacket(userID: originUser.userID),
                                remoteUser: RUPacket(userID: originUser.userID,
                                                     username: originUser.username,
                                                     avatar: originUser.avatar,
                                                     creationDate: creationDate),
                                date: DateU.shared.currSDT)
        
        guard let jsonPacket = try? DataU.shared.jsonEncode(CRPacket),
              let date = DateU.shared.dateFromString(CRPacket.date),
              let RUcreationDate = DateU.shared.dateFromStringZ(remoteUser.creationDate) else { return }
        
        SocketController.shared.clientSocket.emitWithAck("sendCR", ["userID": remoteUser.userID,
                                                                    "packet": jsonPacket])
        .timingOut(after: 1) { [weak self] data in
            guard let self = self else { return }
            
            self.socketCallback(data: data,
                                functionName: "sendCR",
                                failureCompletion: completion) { _ in
                Task {
                    do {
                        let channelRequest = try await DataPC.shared.createChannelRequest(channelID: CRPacket.channel.channelID,
                                                                                          userID: remoteUser.userID,
                                                                                          date: date,
                                                                                          isSender: true)
                        try await self.syncCRs()
                        
                        let sRU = try? await DataPC.shared.createRemoteUser(userID: remoteUser.userID,
                                                                            username: remoteUser.username,
                                                                            avatar: remoteUser.avatar,
                                                                            creationDate: RUcreationDate)
                        if sRU != nil { try await self.syncRUs() }
                        
                        let channel = try await DataPC.shared.createChannel(channelID: CRPacket.channel.channelID,
                                                                            userID: remoteUser.userID,
                                                                            creationDate: date)
                        try await self.syncChannels()
                    } catch {
                        completion(.failure(DCError.failed))
                    }
                }
            }
        }
    }
    
    
    /// sendCRResult:
    ///
    func sendCRResult(channelRequest: SChannelRequest,
                      result: Bool,
                      completion: @escaping (Result<Void, DCError>)->()) {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.sendCRResult: FAILED (disconnected)")
            completion(.failure(.disconnected))
            return
        }
        
        guard let userID = channelRequest.userID else { return }
        let date = DateU.shared.currDT
        
        SocketController.shared.clientSocket.emitWithAck("sendCRResult", ["userID": userID,
                                                                          "packet": ["channelID": channelRequest.channelID,
                                                                                     "date": DateU.shared.stringFromDate(date, TimeZone(identifier: "UTC")!),
                                                                                     "result": result]])
        .timingOut(after: 1) { [weak self] data in
            guard let self = self else { return }
            
            self.socketCallback(data: data,
                                functionName: "sendCRResult",
                                failureCompletion: completion) { _ in
                Task {
                    if (result==true) {
                        do {
                            try await DataPC.shared.fetchDeleteMOAsync(entity: ChannelRequest.self,
                                                                       predicateProperty: "channelID",
                                                                       predicateValue: channelRequest.channelID)
                            try await self.syncCRs()
                            
                            let _ = try await DataPC.shared.updateMO(entity: Channel.self,
                                                                     predicateProperty: "channelID",
                                                                     predicateValue: channelRequest.channelID,
                                                                     property: ["active", "creationDate"],
                                                                     value: [true, date])
                            try await self.syncChannels()
                        } catch {
                            completion(.failure(.failed))
                        }
                    } else if (result==false) {
                        do {
                            try await DataPC.shared.fetchDeleteMOAsync(entity: ChannelRequest.self,
                                                                       predicateProperty: "channelID",
                                                                       predicateValue: channelRequest.channelID)
                            try await self.syncCRs()
                            
                            try await DataPC.shared.fetchDeleteMOAsync(entity: Channel.self,
                                                                       predicateProperty: "channelID",
                                                                       predicateValue: channelRequest.channelID)
                            
                            try await DataPC.shared.fetchDeleteMOAsync(entity: RemoteUser.self,
                                                                       predicateProperty: "userID",
                                                                       predicateValue: channelRequest.userID)
                            try await self.syncRUs()
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
        
        let CDPacket = CDPacket(channelID: channel.channelID,
                                deletionDate: DateU.shared.currSDT,
                                type: type)
        
        guard let jsonPacket = try? DataU.shared.jsonEncode(CDPacket),
              let userID = channel.userID,
              let deletionDate = DateU.shared.dateFromString(CDPacket.deletionDate) else { return }
        
        SocketController.shared.clientSocket.emitWithAck("sendCD", ["userID": userID,
                                                                    "packet": jsonPacket])
        .timingOut(after: 1, callback: { [weak self] data in
            guard let self = self else { return }
            
            self.socketCallback(data: data,
                                functionName: "deleteChannel",
                                failureCompletion: completion) { data in
                
                Task {
                    do {
                        let _ = try await DataPC.shared.createChannelDeletion(deletionID: CDPacket.deletionID,
                                                                              channelType: "user",
                                                                              deletionDate: deletionDate,
                                                                              type: type,
                                                                              name: remoteUser.username,
                                                                              icon: remoteUser.avatar,
                                                                              nUsers: 1,
                                                                              toDeleteUserIDs: [userID],
                                                                              isOrigin: true)
                        try await self.syncCDs()
                        
                        if type=="clear" {
                            // delete channel messages
                            
                            let _ = try await DataPC.shared.updateMO(entity: Channel.self,
                                                                     predicateProperty: "channelID",
                                                                     predicateValue: channel.channelID,
                                                                     property: ["lastMessageDate"],
                                                                     value: [nil])
                           try await self.syncChannels()
                            
                        } else if type=="delete" {
                            // delete channel messages
                            
                            try await DataPC.shared.fetchDeleteMOAsync(entity: Channel.self,
                                                                       predicateProperty: "channelID",
                                                                       predicateValue: channel.channelID)
                            try await self.syncChannels()
                            
                            try await DataPC.shared.fetchDeleteMOAsync(entity: RemoteUser.self,
                                                                       predicateProperty: "userID",
                                                                       predicateValue: channel.userID)
                            try await self.syncRUs()
                        }
                    } catch {
                        completion(.failure(.failed))
                    }
                }
            }
        })
    }
}
