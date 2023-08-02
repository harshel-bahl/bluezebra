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
    
    func fetchRU(userID: String,
                 checkUserID: Bool = true) async throws -> RUPacket {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.fetchRU: FAILED (disconnected)")
            throw DCError.disconnected
        }
        
        if checkUserID {
            guard userID != UserDC.shared.userData?.userID else { throw DCError.invalidRequest }
        }
        
        let packet = try await withCheckedThrowingContinuation() { continuation in
            SocketController.shared.clientSocket.emitWithAck("fetchRU", userID)
                .timingOut(after: 1, callback: { data in
                    do {
                        if let queryStatus = data.first as? String,
                           queryStatus == SocketAckStatus.noAck {
                            throw DCError.timeOut
                        } else if let queryStatus = data.first as? String {
                            throw DCError.serverError(message: queryStatus)
                        } else if data.indices.contains(1),
                                  let _ = data[1] as? NSNull {
                            throw DCError.remoteDataNil
                        } else if let _ = data.first as? NSNull,
                                  data.indices.contains(1) {
                            
                            guard let RUPacket = try? DataU.shared.jsonDecodeFromObject(packet: RUPacket.self,
                                                                                        data: data[1]) else { throw DCError.jsonError }
                            
                            print("SERVER \(DateU.shared.logTS) -- ChannelDC.fetchRU: SUCCESS (userID: \(userID))")
                            continuation.resume(returning: RUPacket)
                        } else {
                            throw DCError.failed
                        }
                    } catch {
                        print("SERVER \(DateU.shared.logTS) -- ChannelDC.fetchRU: FAILED \(error)")
                        continuation.resume(throwing: error)
                    }
                })
        }
        
        return packet
    }
    
    func fetchRUs(username: String,
                  checkUsername: Bool = true) async throws -> [RUPacket] {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.fetchRUs: FAILED (disconnected)")
            throw DCError.disconnected
        }
        
        if checkUsername {
            guard username != UserDC.shared.userData?.username else { throw DCError.invalidRequest }
        }
        
        let packets = try await withCheckedThrowingContinuation() { continuation in
            SocketController.shared.clientSocket.emitWithAck("fetchRUs", username)
                .timingOut(after: 1, callback: { data in
                    
                    do {
                        if let queryStatus = data.first as? String,
                           queryStatus == SocketAckStatus.noAck {
                            throw DCError.timeOut
                        } else if let queryStatus = data.first as? String {
                            throw DCError.serverError(message: queryStatus)
                        } else if let _ = data.first as? NSNull,
                                  data.indices.contains(1) {
                           
                            guard let RUPackets = try? DataU.shared.jsonDecodeFromObject(packet: [RUPacket].self,
                                                                                        data: data[1]) else { throw DCError.jsonError }
                            
                            print("SERVER \(DateU.shared.logTS) -- ChannelDC.fetchRUs: SUCCESS (username: \(username), resultCount: \(RUPackets.count))")
                            continuation.resume(returning: RUPackets)
                        } else {
                            throw DCError.failed
                        }
                    } catch {
                        print("SERVER \(DateU.shared.logTS) -- ChannelDC.fetchRUs: FAILED \(error)")
                        continuation.resume(throwing: error)
                    }
                })
        }
        
        return packets
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
            userIDs.append(channel.userID)
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
    func sendCR(RU: RUPacket,
                checkUserID: Bool = true,
                channelID: String = UUID().uuidString) async throws {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.sendCR: FAILED (disconnected)")
            throw DCError.disconnected
        }
        
        guard let originUser = UserDC.shared.userData else { throw DCError.nilError }
        
        if checkUserID {
            guard RU.userID != UserDC.shared.userData?.userID else { throw DCError.invalidRequest }
        }
        
        do {
            let SCR = try await DataPC.shared.createCR(channelID: channelID,
                                                       userID: RU.userID,
                                                      date: DateU.shared.currDT,
                                                      isSender: true)
            
            guard let RUCreationDate = DateU.shared.dateFromStringZ(RU.creationDate) else { throw DCError.typecastError }
            let SRU = try await DataPC.shared.createRU(userID: RU.userID,
                                                       username: RU.username,
                                                       avatar: RU.avatar,
                                                       creationDate: RUCreationDate)
            
            let SChannel = try await DataPC.shared.createChannel(channelID: channelID,
                                                                 userID: RU.userID,
                                                                 creationDate: SCR.date)
            
            guard let jsonPacket = try? DataU.shared.jsonEncode(data: CRPacket(channel: ChannelPacket(channelID: channelID,
                                                                                                      userID: originUser.userID),
                                                                               remoteUser: RUPacket(userID: originUser.userID,
                                                                                                    username: originUser.username,
                                                                                                    avatar: originUser.avatar,
                                                                                                    creationDate: DateU.shared.stringFromDate(originUser.creationDate, TimeZone(identifier: "UTC")!)),
                                                                               date: DateU.shared.stringFromDate(SCR.date, TimeZone(identifier: "UTC")!))) else { throw DCError.jsonError }
            
            try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("sendCR", ["userID": RU.userID,
                                                                            "packet": jsonPacket])
                .timingOut(after: 1) { [weak self] data in
                    do {
                        guard let self = self else { throw DCError.nilError }
                        
                        if let queryStatus = data.first as? String,
                           queryStatus == SocketAckStatus.noAck {
                            throw DCError.timeOut
                        } else if let queryStatus = data.first as? String {
                            throw DCError.serverError(message: queryStatus)
                        } else if let _ = data.first as? NSNull {
                            print("SERVER \(DateU.shared.logTS) -- ChannelDC.sendCR: SUCCESS (username: \(RU.username))")
                            continuation.resume(returning: ())
                        } else {
                            throw DCError.failed
                        }
                    } catch {
                        print("SERVER \(DateU.shared.logTS) -- ChannelDC.sendCR: FAILED \(error)")
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            self.syncCR(CR: SCR)
            self.syncRU(RU: SRU)
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- ChannelDC.sendCR: FAILED \(error)")
            
            try? await DataPC.shared.fetchDeleteMOsAsync(entity: ChannelRequest.self,
                                                         predicateProperty: "channelID",
                                                         predicateValue: channelID)
            try? await DataPC.shared.fetchDeleteMOsAsync(entity: Channel.self,
                                                         predicateProperty: "channelID",
                                                         predicateValue: channelID)
            try? await DataPC.shared.fetchDeleteMOsAsync(entity: RemoteUser.self,
                                                         predicateProperty: "userID",
                                                         predicateValue: RU.userID)
            throw error
        }
    }
    
    
    /// sendCRResult:
    ///
    func sendCRResult(CR: SChannelRequest,
                      result: Bool,
                      date: Date = DateU.shared.currDT) async throws {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.sendCRResult: FAILED (disconnected)")
            throw DCError.disconnected
        }
        
        try await withCheckedThrowingContinuation() { continuation in
            SocketController.shared.clientSocket.emitWithAck("sendCRResult", ["userID": CR.userID,
                                                                              "packet": ["channelID": CR.channelID,
                                                                                         "date": DateU.shared.stringFromDate(date, TimeZone(identifier: "UTC")!),
                                                                                         "result": result]])
            .timingOut(after: 1) { [weak self] data in
                do {
                    guard let self = self else { throw DCError.nilError }
                    
                    if let queryStatus = data.first as? String,
                       queryStatus == SocketAckStatus.noAck {
                        throw DCError.timeOut
                    } else if let queryStatus = data.first as? String {
                        throw DCError.serverError(message: queryStatus)
                    } else if let _ = data.first as? NSNull {
                        print("SERVER \(DateU.shared.logTS) -- ChannelDC.sendCRResult: SUCCESS (username: \(CR.userID))")
                        
                        Task {
                            do {
                                if (result==true) {
                                    try await DataPC.shared.fetchDeleteMOAsync(entity: ChannelRequest.self,
                                                                               predicateProperty: "channelID",
                                                                               predicateValue: CR.channelID)
                                    self.removeCR(channelID: CR.channelID)
                                    
                                    let SChannel = try await DataPC.shared.updateMO(entity: Channel.self,
                                                                                    predicateProperty: "channelID",
                                                                                    predicateValue: CR.channelID,
                                                                                    property: ["active", "creationDate"],
                                                                                    value: [true, date])
                                    try await self.syncChannels()
                                } else if (result==false) {
                                    try await DataPC.shared.fetchDeleteMOAsync(entity: ChannelRequest.self,
                                                                               predicateProperty: "channelID",
                                                                               predicateValue: CR.channelID)
                                    try await self.syncCRs()
                                    
                                    try await DataPC.shared.fetchDeleteMOAsync(entity: Channel.self,
                                                                               predicateProperty: "channelID",
                                                                               predicateValue: CR.channelID)
                                    
                                    try await DataPC.shared.fetchDeleteMOAsync(entity: RemoteUser.self,
                                                                               predicateProperty: "userID",
                                                                               predicateValue: CR.userID)
                                    try await self.syncRUs()
                                }
                            } catch {
                                
                            }
                        }
                        
                        continuation.resume(returning: ())
                    } else {
                        throw DCError.failed
                    }
                } catch {
                    print("SERVER \(DateU.shared.logTS) -- ChannelDC.sendCRResult: FAILED \(error)")
                    continuation.resume(throwing: error)
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
        
        guard let jsonPacket = try? DataU.shared.jsonEncode(data: CDPacket),
              let deletionDate = DateU.shared.dateFromString(CDPacket.deletionDate) else { return }
        
        SocketController.shared.clientSocket.emitWithAck("sendCD", ["userID": channel.userID,
                                                                    "packet": jsonPacket])
        .timingOut(after: 1, callback: { [weak self] data in
            guard let self = self else { return }
            
            self.socketCallback(data: data,
                                functionName: "deleteChannel",
                                failureCompletion: completion) { data in
                
                Task {
                    do {
                        let _ = try await DataPC.shared.createCD(deletionID: CDPacket.deletionID,
                                                                              channelType: "user",
                                                                              deletionDate: deletionDate,
                                                                              type: type,
                                                                              name: remoteUser.username,
                                                                              icon: remoteUser.avatar,
                                                                              nUsers: 1,
                                                                              toDeleteUserIDs: [channel.userID],
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
