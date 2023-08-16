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
            throw DCError.serverDisconnected(func: "ChannelDC.fetchRU")
        }
        
        guard UserDC.shared.userOnline else {
            throw DCError.userDisconnected(func: "ChannelDC.fetchRU")
        }
        
        if checkUserID {
            guard userID != UserDC.shared.userData?.userID else { throw DCError.invalidRequest(func: "ChannelDC.fetchRU", err: "cannot check for own userID") }
        }
        
        let packet = try await withCheckedThrowingContinuation() { continuation in
            SocketController.shared.clientSocket.emitWithAck("fetchRU", userID)
                .timingOut(after: 1, callback: { data in
                    do {
                        if let queryStatus = data.first as? String,
                           queryStatus == SocketAckStatus.noAck {
                            throw DCError.serverTimeOut(func: "ChannelDC.fetchRU")
                        } else if let queryStatus = data.first as? String {
                            throw DCError.serverFailure(func: "ChannelDC.fetchRU", err: queryStatus)
                        } else if data.indices.contains(1),
                                  let _ = data[1] as? NSNull {
                            throw DCError.remoteDataNil(func: "ChannelDC.fetchRU", err: "userID: \(userID) nil")
                        } else if let _ = data.first as? NSNull,
                                  data.indices.contains(1) {
                            continuation.resume(returning: data[1])
                        } else {
                            throw DCError.serverFailure(func: "ChannelDC.fetchRU")
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                })
        }
        
        let RUPacket = try DataU.shared.jsonDecodeFromObject(packet: RUPacket.self,
                                                             data: packet)
        
        return RUPacket
    }
    
    
    func fetchRUs(username: String,
                  checkUsername: Bool = true) async throws -> [RUPacket] {
        
        guard SocketController.shared.connected else {
            throw DCError.serverDisconnected(func: "ChannelDC.fetchRUs")
        }
        
        guard UserDC.shared.userOnline else {
            throw DCError.userDisconnected(func: "ChannelDC.fetchRUs")
        }
        
        if checkUsername {
            guard username != UserDC.shared.userData?.username else { throw DCError.invalidRequest(func: "ChannelDC.fetchRUs", err: "cannot check for own username") }
        }
        
        let packets = try await withCheckedThrowingContinuation() { continuation in
            SocketController.shared.clientSocket.emitWithAck("fetchRUs", username)
                .timingOut(after: 1, callback: { data in
                    
                    do {
                        if let queryStatus = data.first as? String,
                           queryStatus == SocketAckStatus.noAck {
                            throw DCError.serverTimeOut(func: "ChannelDC.fetchRUs")
                        } else if let queryStatus = data.first as? String {
                            throw DCError.serverFailure(func: "ChannelDC.fetchRUs", err: queryStatus)
                        } else if let _ = data.first as? NSNull,
                                  data.indices.contains(1) {
                            continuation.resume(returning: data[1])
                        } else {
                            throw DCError.serverFailure(func: "ChannelDC.fetchRUs")
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                })
        }
        
        let RUPackets = try DataU.shared.jsonDecodeFromObject(packet: [RUPacket].self,
                                                              data: packets)
        
        return RUPackets
    }
    
    
    /// checkChannelUsers
    ///
    func checkChannelUsers() async throws {
        
        guard SocketController.shared.connected else {
            throw DCError.serverDisconnected(func: "ChannelDC.checkChannelUsers")
        }
        
        guard UserDC.shared.userOnline else {
            throw DCError.userDisconnected(func: "ChannelDC.checkChannelUsers")
        }
        
        let RUIDs = self.RUChannels.map {
            return $0.userID
        }
        
        let result = try await withCheckedThrowingContinuation() { continuation in
            SocketController.shared.clientSocket.emitWithAck("checkChannelUsers", RUIDs)
                .timingOut(after: 1, callback: { data in
                    do {
                        if let queryStatus = data.first as? String,
                           queryStatus == SocketAckStatus.noAck {
                            throw DCError.serverTimeOut(func: "ChannelDC.checkChannelUsers")
                        } else if let queryStatus = data.first as? String {
                            throw DCError.serverFailure(func: "ChannelDC.checkChannelUsers", err: queryStatus)
                        } else if let _ = data.first as? NSNull,
                                  data.indices.contains(1) {
                            continuation.resume(returning: data[1])
                        } else {
                            throw DCError.serverFailure(func: "ChannelDC.checkChannelUsers")
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                })
        }
        
        guard let result = result as? [String: Any] else { throw DCError.typecastError(func: "checkChannelUsers", err: "couldn't cast result to [String: Any]") }
        
        for userID in result.keys {
            do {
                if let userStatus = result[userID] as? Bool,
                   userStatus == false {
                    
                    try await self.deleteUserTrace(userID: userID)
                    
                } else if let userStatus = result[userID] as? String,
                          userStatus == "online" {
                    
                    DispatchQueue.main.async {
                        self.onlineUsers[userID] = true
                    }
                    
                } else if let lastOnline = result[userID] as? String {
                    
                    DispatchQueue.main.async {
                        self.onlineUsers[userID] = false
                    }
                    
                    let lastOnlineDate = try DateU.shared.dateFromStringTZ(lastOnline)
                    
                    let RU = try await DataPC.shared.updateMO(entity: RemoteUser.self,
                                                              predicateProperty: "userID",
                                                              predicateValue: userID,
                                                              property: ["lastOnline"],
                                                              value: [lastOnlineDate])
                    self.syncRU(RU: RU)
                }
            } catch {
                #if DEBUG
                DataU.shared.handleFailure(function: "ChannelDC.checkChannelUsers", err: error, info: "userID: \(userID)")
                #endif
            }
        }
        
        #if DEBUG
        DataU.shared.handleSuccess(function: "ChannelDC.checkChannelUsers", info: "resultCount: \(result.count)")
        #endif
    }
    
    func checkCRs() async throws {
        
        guard SocketController.shared.connected else {
            throw DCError.serverDisconnected(func: "ChannelDC.checkCRs")
        }
        
        guard UserDC.shared.userOnline else {
            throw DCError.userDisconnected(func: "ChannelDC.checkCRs")
        }
        
        let requestIDs = self.CRs.map { $0.requestID }
        
        let result = try await withCheckedThrowingContinuation() { continuation in
            SocketController.shared.clientSocket.emitWithAck("checkCRs", requestIDs)
                .timingOut(after: 1, callback: { data in
                    do {
                        if let queryStatus = data.first as? String,
                           queryStatus == SocketAckStatus.noAck {
                            throw DCError.serverTimeOut(func: "ChannelDC.checkCRs")
                        } else if let queryStatus = data.first as? String {
                            throw DCError.serverFailure(func: "ChannelDC.checkCRs", err: queryStatus)
                        } else if let _ = data.first as? NSNull,
                                  data.indices.contains(1) {
                            continuation.resume(returning: data[1])
                        } else {
                            throw DCError.serverFailure(func: "ChannelDC.checkCRs")
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                })
        }
        
        guard let result = result as? [String: Any] else { throw DCError.typecastError(func: "checkChannelUsers", err: "couldn't cast result to [String: Any]") }
        
        for requestID in result.keys {
            Task {
                if let requestStatus = result[requestID] as? Bool,
                   requestStatus == false {
                    try? await self.deleteCR(requestID: requestID)
                } else if let missingRequest = result[requestID] as? [String: Any] {
                    
                    guard let requestData = missingRequest["packet"] as? Data else { throw DCError.typecastError(func: "checkCRs") }
                    
                    let CRPacket = try DataU.shared.jsonDecodeFromData(packet: CRPacket.self,
                                                                       data: requestData)
                    
                    do {
                        guard let isOrigin = missingRequest["isOrigin"] as? Bool else { throw DCError.jsonError(func: "checkCRs") }
                        
                        let RUCreationDate = try DateU.shared.dateFromStringTZ(CRPacket.originUser.creationDate)
                        let SRU = try await DataPC.shared.createRU(userID: CRPacket.originUser.userID,
                                                                   username: CRPacket.originUser.username,
                                                                   avatar: CRPacket.originUser.avatar,
                                                                   creationDate: RUCreationDate)
                        
                        let requestDate = try DateU.shared.dateFromStringTZ(CRPacket.date)
                        let SCR = try await DataPC.shared.createCR(requestID: requestID,
                                                                   userID: CRPacket.originUser.userID,
                                                                   date: requestDate,
                                                                   isSender: isOrigin)
                    } catch {
                        try? await DataPC.shared.fetchDeleteMO(entity: RemoteUser.self,
                                                               predicateProperty: "userID",
                                                               predicateValue: CRPacket.originUser.userID)
                        
                        try? await DataPC.shared.fetchDeleteMO(entity: ChannelRequest.self,
                                                               predicateProperty: "requestID",
                                                               predicateValue: requestID)
                    }
                }
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
                date: Date = DateU.shared.currDT) async throws {
        
        guard SocketController.shared.connected else {
            throw DCError.serverDisconnected(func: "ChannelDC.sendCR")
        }
        
        guard UserDC.shared.userOnline else {
            throw DCError.userDisconnected(func: "ChannelDC.sendCR")
        }
        
        guard let originUser = UserDC.shared.userData else { throw DCError.nilError(func: "ChannelDC.sendCR", err: "userData is nil") }
        
        if checkUserID {
            guard RU.userID != UserDC.shared.userData?.userID else { throw DCError.invalidRequest(func: "ChannelDC.sendCR", err: "cannot send CR to self") }
        }
        
        let jsonPacket = try DataU.shared.dictionaryToJSONData(["requestID": requestID,
                                                                "date": DateU.shared.stringFromDate(date, TimeZone(identifier: "UTC")!)])
        
        do {
            let SCR = try await DataPC.shared.createCR(requestID: requestID,
                                                       userID: RU.userID,
                                                       date: date,
                                                       isSender: true)
            
            let SRU = try await DataPC.shared.createRU(userID: RU.userID,
                                                       username: RU.username,
                                                       avatar: RU.avatar,
                                                       creationDate: try DateU.shared.dateFromStringTZ(RU.creationDate))
            
            try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("sendCR", ["userID": RU.userID,
                                                                            "packet": jsonPacket] as [String : Any])
                .timingOut(after: 1) { data in
                    do {
                        if let queryStatus = data.first as? String,
                           queryStatus == SocketAckStatus.noAck {
                            throw DCError.serverTimeOut(func: "ChannelDC.sendCR")
                        } else if let queryStatus = data.first as? String {
                            throw DCError.serverFailure(func: "ChannelDC.sendCR", err: queryStatus)
                        } else if let _ = data.first as? NSNull {
                            continuation.resume(returning: ())
                        } else {
                            throw DCError.serverFailure(func: "ChannelDC.sendCR")
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            self.syncCR(CR: SCR)
            self.syncRU(RU: SRU)
        } catch {
            try? await DataPC.shared.fetchDeleteMO(entity: ChannelRequest.self,
                                                   predicateProperty: "requestID",
                                                   predicateValue: requestID)
            
            try? await DataPC.shared.fetchDeleteMO(entity: RemoteUser.self,
                                                   predicateProperty: "userID",
                                                   predicateValue: RU.userID)
            throw error
        }
    }
    
    /// sendCRResult:
    /// -
    func sendCRResult(CR: SChannelRequest,
                      result: Bool,
                      channelID: String = UUID().uuidString,
                      creationDate: Date = DateU.shared.currDT) async throws {
        
        guard SocketController.shared.connected else {
            throw DCError.serverDisconnected(func: "ChannelDC.sendCRResult")
        }
        
        guard UserDC.shared.userOnline else {
            throw DCError.userDisconnected(func: "ChannelDC.sendCRResult")
        }
        
        let jsonPacket = try DataU.shared.dictionaryToJSONData(["requestID": CR.requestID,
                                                                "result": result,
                                                                "channelID": channelID,
                                                                "creationDate": DateU.shared.stringFromDate(creationDate, TimeZone(identifier: "UTC")!)])
        
        try await withCheckedThrowingContinuation() { continuation in
            SocketController.shared.clientSocket.emitWithAck("sendCRResult", ["userID": CR.userID,
                                                                              "packet": jsonPacket] as [String : Any])
            .timingOut(after: 1) { [weak self] data in
                do {
                    guard let self = self else { throw DCError.nilError(func: "sendCRResult", err: "self is nil") }
                    
                    if let queryStatus = data.first as? String,
                       queryStatus == SocketAckStatus.noAck {
                        throw DCError.serverTimeOut(func: "ChannelDC.sendCRResult")
                    } else if let queryStatus = data.first as? String {
                        throw DCError.serverFailure(func: "ChannelDC.sendCRResult", err: queryStatus)
                    } else if let _ = data.first as? NSNull {
                        continuation.resume(returning: ())
                    } else {
                        throw DCError.serverFailure(func: "ChannelDC.sendCRResult")
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
        
        if (result == true) {
            try await DataPC.shared.fetchDeleteMO(entity: ChannelRequest.self,
                                                  predicateProperty: "requestID",
                                                  predicateValue: CR.requestID)
            self.removeCR(requestID: CR.requestID)
            
            let SChannel = try await self.createChannel(channelID: channelID,
                                                        userID: CR.userID,
                                                        creationDate: creationDate)
            self.syncChannel(channel: SChannel)
        } else if (result == false) {
            try await DataPC.shared.fetchDeleteMO(entity: ChannelRequest.self,
                                                  predicateProperty: "requestID",
                                                  predicateValue: CR.requestID)
            self.removeCR(requestID: CR.requestID)
            
            try await DataPC.shared.fetchDeleteMO(entity: RemoteUser.self,
                                                  predicateProperty: "userID",
                                                  predicateValue: CR.userID)
            self.removeRU(userID: CR.userID)
        }
    }
    
    func sendCD(channel: SChannel,
                RU: SRemoteUser,
                deletionID: String = UUID().uuidString,
                type: String = "clear",
                deletionDate: Date = DateU.shared.currDT) async throws {
        
        guard SocketController.shared.connected else {
            throw DCError.serverDisconnected(func: "ChannelDC.sendCD")
        }
        
        guard UserDC.shared.userOnline else {
            throw DCError.userDisconnected(func: "ChannelDC.sendCD")
        }
        
        let jsonPacket = try DataU.shared.dictionaryToJSONData(["deletionID": deletionID,
                                                                "deletionDate": DateU.shared.stringFromDate(deletionDate, TimeZone(identifier: "UTC")!),
                                                                "type": type,
                                                                "channelID": channel.channelID])
        do {
            if type == "clear" {
                MessageDC.shared.channelMessages.removeValue(forKey: channel.channelID)
            } else if type == "delete" {
                self.removeChannel(channelID: channel.channelID)
            }
            
            try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("sendCD", ["userID": RU.userID,
                                                                            "packet": jsonPacket] as [String : Any])
                .timingOut(after: 1) { data in
                    do {
                        if let queryStatus = data.first as? String,
                           queryStatus == SocketAckStatus.noAck {
                            throw DCError.serverTimeOut(func: "ChannelDC.sendCD")
                        } else if let queryStatus = data.first as? String {
                            throw DCError.serverFailure(func: "ChannelDC.sendCD", err: queryStatus)
                        } else if let _ = data.first as? NSNull {
                            continuation.resume(returning: ())
                        } else {
                            throw DCError.serverFailure(func: "ChannelDC.sendCD")
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
            
            let SCD = try await DataPC.shared.createCD(deletionID: deletionID,
                                                       channelType: "RU",
                                                       deletionDate: deletionDate,
                                                       type: type,
                                                       name: RU.username,
                                                       icon: RU.avatar,
                                                       nUsers: 1,
                                                       toDeleteUserIDs: [RU.userID],
                                                       isOrigin: true)
            self.syncCD(CD: SCD)
            
            if type == "clear" {
                let SChannel = try await DataPC.shared.updateMO(entity: Channel.self,
                                                                predicateProperty: "channelID",
                                                                predicateValue: channel.channelID,
                                                                property: ["lastMessageDate"],
                                                                value: [nil])
                self.syncChannel(channel: SChannel)
                
                try await MessageDC.shared.clearChannelMessages(channelID: channel.channelID)
            } else if type == "delete" {
                try await DataPC.shared.fetchDeleteMO(entity: Channel.self,
                                                      predicateProperty: "channelID",
                                                      predicateValue: channel.channelID)
                
                try await DataPC.shared.fetchDeleteMO(entity: RemoteUser.self,
                                                      predicateProperty: "userID",
                                                      predicateValue: RU.userID)
                self.removeRU(userID: RU.userID)
                
                try await MessageDC.shared.deleteChannelMessages(channelID: channel.channelID)
            }
        } catch {
            if type == "clear" {
                try? await MessageDC.shared.syncChannel(channelID: channel.channelID)
            } else if type == "delete" {
                if let SChannel = try? await DataPC.shared.fetchSMO(entity: Channel.self,
                                                                    predicateProperty: "channelID",
                                                                    predicateValue: channel.channelID) {
                    self.syncChannel(channel: SChannel)
                }
            }
            
            throw error
        }
    }
    
    func sendCDResult(deletionID: String,
                      userID: String,
                      date: Date = DateU.shared.currDT) async throws {
        
        guard SocketController.shared.connected else {
            throw DCError.serverDisconnected(func: "ChannelDC.sendCDResult")
        }
        
        guard UserDC.shared.userOnline else {
            throw DCError.userDisconnected(func: "ChannelDC.sendCDResult")
        }
        
        guard let originUser = UserDC.shared.userData else { throw DCError.nilError(func: "ChannelDC.sendCR", err: "userData is nil") }
        
        let jsonPacket = try DataU.shared.dictionaryToJSONData(["deletionID": deletionID,
                                                                "userID": originUser.userID,
                                                                "date": DateU.shared.stringFromDate(date, TimeZone(identifier: "UTC")!)])

        try await withCheckedThrowingContinuation() { continuation in
            SocketController.shared.clientSocket.emitWithAck("sendCDResult", ["userID": userID,
                                                                              "packet": jsonPacket] as [String : Any])
            .timingOut(after: 1) { data in
                do {
                    if let queryStatus = data.first as? String,
                       queryStatus == SocketAckStatus.noAck {
                        throw DCError.serverTimeOut(func: "ChannelDC.resetChannels")
                    } else if let queryStatus = data.first as? String {
                        throw DCError.serverFailure(func: "ChannelDC.resetChannels", err: queryStatus)
                    } else if let _ = data.first as? NSNull {
                        continuation.resume(returning: ())
                    } else {
                        throw DCError.serverFailure(func: "ChannelDC.resetChannels")
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    
    func resetChannels(deletionDate: Date = DateU.shared.currDT) async throws {
        
        guard SocketController.shared.connected else {
            throw DCError.serverDisconnected(func: "ChannelDC.resetChannels")
        }
        
        guard UserDC.shared.userOnline else {
            throw DCError.userDisconnected(func: "ChannelDC.resetChannels")
        }
        
        let predicate = NSPredicate(format: "channelID != %@", argumentArray: ["personal"])
        
        let RUChannels = try await DataPC.shared.fetchSMOs(entity: Channel.self,
                                                           customPredicate: predicate)
        
        let deletionDateS = DateU.shared.stringFromDate(deletionDate, TimeZone(identifier: "UTC")!)
        
        var deletionPackets = [[String: String]]()
        
        for channel in RUChannels {
            deletionPackets.append(["channelID": channel.channelID,
                                    "userID": channel.userID,
                                    "deletionID": UUID().uuidString,
                                    "deletionDate": deletionDateS])
        }
        
        let jsonPacket = try DataU.shared.arrayToJSONData(deletionPackets)
        
        try await withCheckedThrowingContinuation() { continuation in
            SocketController.shared.clientSocket.emitWithAck("resetChannels", ["packet": jsonPacket] as [String : Any])
            .timingOut(after: 1) { data in
                do {
                    if let queryStatus = data.first as? String,
                       queryStatus == SocketAckStatus.noAck {
                        throw DCError.serverTimeOut(func: "ChannelDC.resetChannels")
                    } else if let queryStatus = data.first as? String {
                        throw DCError.serverFailure(func: "ChannelDC.resetChannels", err: queryStatus)
                    } else if let _ = data.first as? NSNull {
                        continuation.resume(returning: ())
                    } else {
                        throw DCError.serverFailure(func: "ChannelDC.resetChannels")
                    }
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
        
        for deletionData in deletionPackets {
            do {
                guard let channelID = deletionData["channelID"],
                      let userID = deletionData["userID"],
                      let deletionID = deletionData["deletionID"] else { throw DCError.nilError(func: "resetChannels") }
                
                let RU = try await DataPC.shared.fetchSMO(entity: RemoteUser.self,
                                                          predicateProperty: "userID",
                                                          predicateValue: userID)
                
                let SCD = try await self.clearChannelData(channelID: channelID,
                                                          RU: RU,
                                                          deletionID: deletionID,
                                                          deletionDate: deletionDate,
                                                          isOrigin: true)
                
                self.syncCD(CD: SCD)
            } catch {
                
            }
        }
    }
}
