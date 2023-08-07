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
    
    
    /// checkChannelUsers
    ///
    func checkChannelUsers() async throws {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.checkChannelUsers: FAILED (disconnected)")
            throw DCError.disconnected
        }
        
        let RUIDs = self.channels.map {
            return $0.userID
        }
        
        let result = try await withCheckedThrowingContinuation() { continuation in
            SocketController.shared.clientSocket.emitWithAck("checkChannelUsers", RUIDs)
                .timingOut(after: 1, callback: { [weak self] data in
                    guard let self = self else { return }
                    
                    do {
                        if let queryStatus = data.first as? String,
                           queryStatus == SocketAckStatus.noAck {
                            throw DCError.timeOut
                        } else if let queryStatus = data.first as? String {
                            throw DCError.serverError(message: queryStatus)
                        } else if let _ = data.first as? NSNull,
                                  data.indices.contains(1),
                                  let result = data[1] as? [String: Any] {
                            print("SERVER \(DateU.shared.logTS) -- UserDC.checkChannelUsers: SUCCESS (RUID count: \(RUIDs.count))")
                            continuation.resume(returning: result)
                        } else {
                            throw DCError.failed
                        }
                    } catch {
                        print("SERVER \(DateU.shared.logTS) -- UserDC.checkChannelUsers: FAILED (error: \(error))")
                        continuation.resume(throwing: error)
                    }
                })
        }
        
        for userID in result.keys {
            do {
                if let userStatus = result[userID] as? Bool,
                   userStatus == false {
                    
                    try await self.deleteUserTrace(userID: userID)
                    
                } else if let userStatus = result[userID] as? String,
                          userStatus == "online" {
                    self.onlineUsers[userID] = true
                } else if let lastOnline = result[userID] as? String {
                    self.onlineUsers[userID] = false
                    
                    guard let lastOnlineDate = DateU.shared.dateFromStringTZ(lastOnline) else { throw DCError.jsonError }
                    
                    let RU = try await DataPC.shared.updateMO(entity: RemoteUser.self,
                                                              property: ["lastOnline"],
                                                              value: [lastOnlineDate])
                    self.syncRU(RU: RU)
                }
            } catch {
                print("CLIENT \(DateU.shared.logTS) -- UserDC.checkChannelUsers: FAILED (userID: \(userID), error: \(error))")
            }
        }
    }
    
    /// sendCR:
    /// - Failure event is created first in local persistence in case of A going offline suddenly so that event can be emitted on next startup
    /// - Sends request to server and awaits ack
    ///     - If ack is null, local objects are created
    ///     - If ack is errored or timeOut, local objects aren't created
    /// - If local persistence errors, then a sendCRFailure is emitted after all objects are deleted and the corresponding failure event is removed from local persistence on successful emit of failure event
    func sendCR(RU: RUPacket,
                checkUserID: Bool = true,
                requestID: String = UUID().uuidString,
                channelID: String = UUID().uuidString,
                date: Date = DateU.shared.currDT) async throws {
        
        guard SocketController.shared.connected else {
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.sendCR: FAILED (disconnected)")
            throw DCError.disconnected
        }
        
        guard let originUser = UserDC.shared.userData else { throw DCError.nilError }
        
        if checkUserID {
            guard RU.userID != UserDC.shared.userData?.userID else { throw DCError.invalidRequest }
        }
        
        let CRPacket = CRPacket(requestID: requestID,
                                date: DateU.shared.stringFromDate(date, TimeZone(identifier: "UTC")!),
                                channel: ChannelPacket(channelID: channelID,
                                                       userID: originUser.userID),
                                remoteUser: RUPacket(userID: originUser.userID,
                                                     username: originUser.username,
                                                     avatar: originUser.avatar,
                                                     creationDate: DateU.shared.stringFromDate(originUser.creationDate, TimeZone(identifier: "UTC")!)))
        
        guard let jsonPacket = try? DataU.shared.jsonEncode(data: CRPacket) else { throw DCError.jsonError }
        
        guard let failureJSONPacket = try? DataU.shared.dictionaryToJSONData(["requestID": requestID,
                                                                              "channelID": channelID,
                                                                              "userID": originUser.userID]) else { throw DCError.jsonError }
        
        let failureEvent = try await DataPC.shared.createEvent(eventID: UUID().uuidString,
                                                               eventName: "sendCRFailure",
                                                               date: DateU.shared.currDT,
                                                               userID: RU.userID,
                                                               attempts: 0,
                                                               packet: failureJSONPacket)
        
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
                    print("SERVER \(DateU.shared.logTS) -- ChannelDC.sendCR: FAILED (username: \(RU.username), error: \(error))")
                    continuation.resume(throwing: error)
                }
            }
        }
        
        do {
            let SCR = try await DataPC.shared.createCR(requestID: requestID,
                                                       channelID: channelID,
                                                       userID: RU.userID,
                                                       date: date,
                                                       isSender: true)
            
            guard let RUCreationDate = DateU.shared.dateFromStringTZ(RU.creationDate) else { throw DCError.typecastError }
            let SRU = try await DataPC.shared.createRU(userID: RU.userID,
                                                       username: RU.username,
                                                       avatar: RU.avatar,
                                                       creationDate: RUCreationDate)
            
            let SChannel = try await DataPC.shared.createChannel(channelID: channelID,
                                                                 active: false,
                                                                 userID: RU.userID,
                                                                 creationDate: SCR.date)
            self.syncCR(CR: SCR)
            self.syncRU(RU: SRU)
            
            try await DataPC.shared.fetchDeleteMOAsync(entity: Event.self,
                                                        predicateProperty: "eventID",
                                                        predicateValue: failureEvent.eventID)
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- ChannelDC.sendCR: FAILED (username: \(RU.username), error: \(error))")
            
            try await self.sendCRFailure(failureEvent: failureEvent)
            
            throw error
        }
    }
    
    /// sendCRFailure
    /// - Handles a failure of client A to persist local CR data or a failure of client B to persist local CR data (if ack doesn't get sent successfully from client B)
    /// - If client shuts down during creation, then on startup this event will be fired to clean up the data on client A and B
    /// - Assumes that a failure event has already been persisted before being fired, hence this function will remove the event on successful ack
    func sendCRFailure(failureEvent: SEvent) async throws {
        
        guard SocketController.shared.connected else {
            throw DCError.disconnected
        }
        
        guard let jsonPacket = failureEvent.packet else { throw DCError.nilError }
        
        let dic = try DataU.shared.jsonDataToDictionary(jsonPacket)
        
        guard let requestID = dic["requestID"] as? String,
              let channelID = dic["channelID"] as? String,
              let userID = dic["userID"] as? String else { throw DCError.jsonError }
        
        try await withCheckedThrowingContinuation() { continuation in
            SocketController.shared.clientSocket.emitWithAck("sendCRFailure", ["userID": failureEvent.userID,
                                                                               "packet": jsonPacket])
            .timingOut(after: 1) { data in
                do {
                    if let queryStatus = data.first as? String,
                       queryStatus == SocketAckStatus.noAck {
                        throw DCError.timeOut
                    } else if let queryStatus = data.first as? String {
                        throw DCError.serverError(message: queryStatus)
                    } else if let _ = data.first as? NSNull {
                        print("SERVER \(DateU.shared.logTS) -- ChannelDC.sendCRFailure: SUCCESS (requestID: \(requestID))")
                        continuation.resume(returning: ())
                    } else {
                        throw DCError.failed
                    }
                } catch {
                    print("SERVER \(DateU.shared.logTS) -- ChannelDC.sendCRFailure: FAILED (requestID: \(requestID), error: \(error))")
                    continuation.resume(throwing: error)
                }
            }
        }
        
        try? await DataPC.shared.fetchDeleteMOAsync(entity: ChannelRequest.self,
                                                    predicateProperty: "requestID",
                                                    predicateValue: requestID)
        try? await DataPC.shared.fetchDeleteMOAsync(entity: Channel.self,
                                                    predicateProperty: "channelID",
                                                    predicateValue: channelID)
        try? await DataPC.shared.fetchDeleteMOAsync(entity: RemoteUser.self,
                                                    predicateProperty: "userID",
                                                    predicateValue: userID)
        try? await DataPC.shared.fetchDeleteMOAsync(entity: Event.self,
                                                    predicateProperty: "eventID",
                                                    predicateValue: failureEvent.eventID)
    }
    
    
    /// sendCRResult:
    /// -
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
    
    func checkFailures() async throws {
        
    }
    
    func resetChannels() async throws {
        
    }
}
