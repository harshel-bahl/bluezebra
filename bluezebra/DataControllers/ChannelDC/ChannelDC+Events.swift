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
    
    func fetchRU(uID: UUID,
                 checkuID: Bool = true) async throws -> RUPacket {
        
        do {
            guard SocketController.shared.connected else {
                throw DCError.serverDisconnected(func: "ChannelDC.fetchRU")
            }
            
            guard UserDC.shared.userOnline else {
                throw DCError.userDisconnected(func: "ChannelDC.fetchRU")
            }
            
            if checkuID {
                guard uID != UserDC.shared.userData?.uID else { throw DCError.invalidRequest(func: "ChannelDC.fetchRU", err: "cannot check for own uID") }
            }
            
            let packet = try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("fetchRU", uID)
                    .timingOut(after: 1, callback: { data in
                        do {
                            if let queryStatus = data.first as? String,
                               queryStatus == SocketAckStatus.noAck {
                                throw DCError.serverTimeOut(func: "ChannelDC.fetchRU")
                            } else if let queryStatus = data.first as? String {
                                throw DCError.serverFailure(func: "ChannelDC.fetchRU", err: queryStatus)
                            } else if data.indices.contains(1),
                                      let _ = data[1] as? NSNull {
                                throw DCError.remoteDataNil(func: "ChannelDC.fetchRU", err: "uID: \(uID) nil")
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
            
#if DEBUG
            DataU.shared.handleSuccess(function: "ChannelDC.fetchRU")
#endif
            
            return RUPacket
        } catch {
#if DEBUG
            DataU.shared.handleFailure(function: "ChannelDC.fetchRU", err: error)
#endif
            
            throw error
        }
    }
    
    
    func fetchRUs(username: String,
                  checkUsername: Bool = true) async throws -> [RUPacket] {
        
        do {
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
            
#if DEBUG
            DataU.shared.handleSuccess(function: "ChannelDC.fetchRUs")
#endif
            
            return RUPackets
        } catch {
#if DEBUG
            DataU.shared.handleFailure(function: "ChannelDC.fetchRUs", err: error)
#endif
            
            throw error
        }
    }
    
    /// checkCRs
    /// - checks the list of all CRs in device with CRs in server
    /// - if device has a CR that server doesn't then the CR and associated RU is deleted from device
    /// - if server has a CR that device doesn't then the CR and associated RU is created in device
    /// 
    func checkCRs(requestIDs: [String]) async throws {
        
        do {
            guard SocketController.shared.connected else {
                throw DCError.serverDisconnected(func: "ChannelDC.checkCRs")
            }
            
            guard UserDC.shared.userOnline else {
                throw DCError.userDisconnected(func: "ChannelDC.checkCRs")
            }
            
            let packet = try await withCheckedThrowingContinuation() { continuation in
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
            
            guard let jsonObject = packet as? [String: Any] else { throw DCError.typecastError(func: "ChannelDC.checkCRs") }
            
            for requestID in jsonObject.keys {
                do {
                    if let requestStatus = jsonObject[requestID] as? Bool,
                       requestStatus == false {
                        try await self.deleteCR(requestID: requestID)
                    } else if let missingRequest = jsonObject[requestID] {
                        
                        guard let missingRequest = missingRequest as? [String: Any],
                              let packetData = missingRequest["packet"] as? Data else { throw DCError.typecastError(func: "ChannelDC.checkCRs") }
                        
                        guard let isOrigin = missingRequest["isOrigin"] as? Bool else { throw DCError.jsonError(func: "ChannelDC.checkCRs") }
                        
                        let CRPacket = try DataU.shared.jsonDecodeFromData(packet: CRPacket.self,
                                                                           data: packetData)
                        
                        let SCR = try await DataPC.shared.createCR(requestID: requestID,
                                                                   uID: CRPacket.originUser.uID,
                                                                   date: try DateU.shared.dateFromStringTZ(CRPacket.date),
                                                                   isSender: isOrigin)
                        self.syncCR(CR: SCR)
                        
                        if let _ = try? await self.fetchRULocally(uID: CRPacket.originUser.uID) {
                            try await self.deleteRU(uID: CRPacket.originUser.uID)
                        }
                        
                        let SRU = try await DataPC.shared.createRU(uID: CRPacket.originUser.uID,
                                                                   username: CRPacket.originUser.username,
                                                                   avatar: CRPacket.originUser.avatar,
                                                                   creationDate: try DateU.shared.dateFromStringTZ(CRPacket.originUser.creationDate))
                        
                    }
                    
#if DEBUG
                    DataU.shared.handleSuccess(function: "ChannelDC.checkCRs", info: "requestID: \(requestID)")
#endif
                } catch {
#if DEBUG
                    DataU.shared.handleFailure(function: "ChannelDC.checkCRs", err: error, info: "requestID: \(requestID)")
#endif
                }
            }
            
#if DEBUG
            DataU.shared.handleSuccess(function: "ChannelDC.checkCRs")
#endif
        } catch {
#if DEBUG
            DataU.shared.handleFailure(function: "ChannelDC.checkCRs", err: error)
#endif
            
            throw error
        }
    }
    
    
    /// checkRUChannels
    ///
    func checkRUChannels(channelIDs: [String]) async throws {
        do {
            guard SocketController.shared.connected else {
                throw DCError.serverDisconnected(func: "ChannelDC.checkRUChannels")
            }
            
            guard UserDC.shared.userOnline else {
                throw DCError.userDisconnected(func: "ChannelDC.checkRUChannels")
            }
            
            let packet = try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("checkRUChannels", channelIDs)
                    .timingOut(after: 1, callback: { data in
                        do {
                            if let queryStatus = data.first as? String,
                               queryStatus == SocketAckStatus.noAck {
                                throw DCError.serverTimeOut(func: "ChannelDC.checkRUChannels")
                            } else if let queryStatus = data.first as? String {
                                throw DCError.serverFailure(func: "ChannelDC.checkRUChannels", err: queryStatus)
                            } else if let _ = data.first as? NSNull,
                                      data.indices.contains(1) {
                                continuation.resume(returning: data[1])
                            } else {
                                throw DCError.serverFailure(func: "ChannelDC.checkRUChannels")
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    })
            }
            
            guard let packet = packet as? [String: Any] else { throw DCError.typecastError(func: "checkRUChannels", err: "couldn't cast result to [String: Any]") }
            
            var channelsRemoved = [String]()
            
            for channelID in packet.keys {
                do {
                    if let channelStatus = packet[channelID] as? Bool,
                       channelStatus == false {
                        
                        let SChannel = try await self.fetchChannelLocally(channelID: channelID)
                        
                        try await self.deleteUserTrace(uID: SChannel.uID)
                        
                        channelsRemoved.append(channelID)
                    }
#if DEBUG
            DataU.shared.handleSuccess(function: "ChannelDC.checkRUChannels", info: "channelID: \(channelID)")
#endif
                } catch {
#if DEBUG
                    DataU.shared.handleFailure(function: "ChannelDC.checkRUChannels", err: error, info: "channelID: \(channelID)")
#endif
                }
            }
            
#if DEBUG
            DataU.shared.handleSuccess(function: "ChannelDC.checkRUChannels", info: "channelsRemoved: \(channelsRemoved)")
#endif
        } catch {
#if DEBUG
            DataU.shared.handleFailure(function: "ChannelDC.checkRUChannels", err: error)
#endif
            
            throw error
        }
    }
    
    func checkMissingRUChannels() async throws {
        do {
            guard SocketController.shared.connected else {
                throw DCError.serverDisconnected(func: "ChannelDC.checkMissingRUChannels")
            }
            
            guard UserDC.shared.userOnline else {
                throw DCError.userDisconnected(func: "ChannelDC.checkMissingRUChannels")
            }
            
            let predicate = NSPredicate(format: "channelID != %@", argumentArray: ["personal"])
            
            let channels = try await DataPC.shared.fetchSMOs(entity: Channel.self,
                                                             customPredicate: predicate)
            
            let channelIDs = channels.map { return $0.channelID }
            
            let packet = try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("checkMissingRUChannels", channelIDs)
                    .timingOut(after: 1, callback: { data in
                        do {
                            if let queryStatus = data.first as? String,
                               queryStatus == SocketAckStatus.noAck {
                                throw DCError.serverTimeOut(func: "ChannelDC.checkMissingRUChannels")
                            } else if let queryStatus = data.first as? String {
                                throw DCError.serverFailure(func: "ChannelDC.checkMissingRUChannels", err: queryStatus)
                            } else if let _ = data.first as? NSNull,
                                      data.indices.contains(1) {
                                continuation.resume(returning: data[1])
                            } else {
                                throw DCError.serverFailure(func: "ChannelDC.checkMissingRUChannels")
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    })
            }
            
            guard let packet = packet as? [String: Any] else { throw DCError.typecastError(func: "ChannelDC.checkMissingRUChannels", err: "couldn't cast result to [String: Any]") }
            
            var channelsAdded = [String]()
            
            for channelID in packet.keys {
                do {
                    guard let packetData = packet[channelID] as? Data else { throw DCError.typecastError(func: "ChannelDC.checkMissingRUChannels", err: "couldn't cast to Data") }
                    
                    let channelData = try DataU.shared.jsonDataToDictionary(packetData)
                    
                    guard let creationDateS = channelData["creationDate"] as? String,
                          let RU = channelData["RU"] as? Data else { throw DCError.jsonError(func: "ChannelDC.checkMissingRUChannels") }
                    
                    let RUPacket = try DataU.shared.jsonDecodeFromData(packet: RUPacket.self,
                                                                       data: RU)
                    
                    try await self.createChannel(channelID: channelID,
                                                 uID: RUPacket.uID,
                                                 creationDate: try DateU.shared.dateFromStringTZ(creationDateS))
                    
                    if let _ = try? await self.fetchRULocally(uID: RUPacket.uID) {
                        try await self.deleteRU(uID: RUPacket.uID)
                    }
                    
                    let SRU = try await DataPC.shared.createRU(uID: RUPacket.uID,
                                                               username: RUPacket.username,
                                                               avatar: RUPacket.avatar,
                                                               creationDate: try DateU.shared.dateFromStringTZ(RUPacket.creationDate))
                    
                    channelsAdded.append(channelID)
#if DEBUG
                    DataU.shared.handleSuccess(function: "ChannelDC.checkMissingRUChannels", info: "channelID: \(channelID)")
#endif
                } catch {
#if DEBUG
                    DataU.shared.handleFailure(function: "ChannelDC.checkMissingRUChannels", err: error, info: "channelID: \(channelID)")
#endif
                }
            }
            
#if DEBUG
            DataU.shared.handleSuccess(function: "ChannelDC.checkMissingRUChannels", info: "channelsAdded: \(channelsAdded)")
#endif
        } catch {
#if DEBUG
            DataU.shared.handleFailure(function: "ChannelDC.checkMissingRUChannels", err: error)
#endif
            
            throw error
        }
    }
    
    func checkOnline(uIDs: [String]) async throws {
        do {
            guard SocketController.shared.connected else {
                throw DCError.serverDisconnected(func: "ChannelDC.checkOnline")
            }
            
            guard UserDC.shared.userOnline else {
                throw DCError.userDisconnected(func: "ChannelDC.checkOnline")
            }
            
            let packet = try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("checkOnline", uIDs)
                    .timingOut(after: 1, callback: { data in
                        do {
                            if let queryStatus = data.first as? String,
                               queryStatus == SocketAckStatus.noAck {
                                throw DCError.serverTimeOut(func: "ChannelDC.checkOnline")
                            } else if let queryStatus = data.first as? String {
                                throw DCError.serverFailure(func: "ChannelDC.checkOnline", err: queryStatus)
                            } else if let _ = data.first as? NSNull,
                                      data.indices.contains(1) {
                                continuation.resume(returning: data[1])
                            } else {
                                throw DCError.serverFailure(func: "ChannelDC.checkOnline")
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    })
            }
            
            guard let packet = packet as? [String: Any] else { throw DCError.typecastError(func: "ChannelDC.checkOnline", err: "couldn't cast result to [String: Any]") }
            
            var RUStatusUpdated = 0
            
            for uID in packet.keys {
                do {
                    if let userStatus = packet[uID] as? Bool,
                       userStatus == true {
                        
                        DispatchQueue.main.async {
                            self.onlineUsers[uID] = true
                        }
                        
                    } else if let lastOnline = packet[uID] as? String {
                        
                        DispatchQueue.main.async {
                            self.onlineUsers[uID] = false
                        }
                        
                        let RULastOnline = try DateU.shared.dateFromStringTZ(lastOnline)
                        
                        let RU = try await DataPC.shared.updateMO(entity: RemoteUser.self,
                                                                  predicateProperty: "uID",
                                                                  predicateValue: uID,
                                                                  property: ["lastOnline"],
                                                                  value: [RULastOnline])
                    }
                    
                    RUStatusUpdated += 1
                } catch {
#if DEBUG
                    DataU.shared.handleFailure(function: "ChannelDC.checkOnline", err: error, info: "uID: \(uID)")
#endif
                }
            }
            
#if DEBUG
            DataU.shared.handleSuccess(function: "ChannelDC.checkOnline", info: "RUStatusUpdated: \(RUStatusUpdated)")
#endif
        } catch {
#if DEBUG
            DataU.shared.handleFailure(function: "ChannelDC.checkOnline", err: error)
#endif
            
            throw error
        }
    }
    
    /// sendCR:
    /// - Failure event is created first in local persistence in case of A going offline suddenly so that event can be emitted on next startup
    /// - Sends request to server and awaits ack
    ///     - If ack is null, local objects are created
    ///     - If ack is errored or timeOut, local objects aren't created
    /// - If local persistence errors, then a sendCRFailure is emitted after all objects are deleted and the corresponding failure event is removed from local persistence on successful emit of failure event
    func sendCR(RU: RUPacket,
                checkuID: Bool = true,
                requestID: String = UuID().uuidString,
                date: Date = DateU.shared.currDT) async throws {
        do {
            guard SocketController.shared.connected else {
                throw DCError.serverDisconnected(func: "ChannelDC.sendCR")
            }
            
            guard UserDC.shared.userOnline else {
                throw DCError.userDisconnected(func: "ChannelDC.sendCR")
            }
            
            guard let originUser = UserDC.shared.userData else { throw DCError.nilError(func: "ChannelDC.sendCR", err: "userData is nil") }
            
            if checkuID {
                guard RU.uID != UserDC.shared.userData?.uID else { throw DCError.invalidRequest(func: "ChannelDC.sendCR", err: "cannot send CR to self") }
            }
            
            let jsonPacket = try DataU.shared.dictionaryToJSONData(["requestID": requestID,
                                                                    "date": DateU.shared.stringFromDate(date, TimeZone(identifier: "UTC")!)])
            
            try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("sendCR", ["uID": RU.uID,
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
            
            let SCR = try await DataPC.shared.createCR(requestID: requestID,
                                                       uID: RU.uID,
                                                       date: date,
                                                       isSender: true)
            
            let SRU = try await DataPC.shared.createRU(uID: RU.uID,
                                                       username: RU.username,
                                                       avatar: RU.avatar,
                                                       creationDate: try DateU.shared.dateFromStringTZ(RU.creationDate))
            self.syncCR(CR: SCR)
            
#if DEBUG
            DataU.shared.handleSuccess(function: "ChannelDC.sendCR", info: "RuID: \(RU.uID)")
#endif
        } catch {
#if DEBUG
            DataU.shared.handleFailure(function: "ChannelDC.sendCR", err: error)
#endif
            throw error
        }
    }
    
    /// sendCRResult:
    /// -
    func sendCRResult(CR: SChannelRequest,
                      result: Bool,
                      channelID: String = UuID().uuidString,
                      creationDate: Date = DateU.shared.currDT) async throws {
        
        do {
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
                SocketController.shared.clientSocket.emitWithAck("sendCRResult", ["uID": CR.uID,
                                                                                  "packet": jsonPacket] as [String : Any])
                .timingOut(after: 1) { data in
                    do {
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
                try await self.deleteCR(requestID: CR.requestID)
                
                try await self.createChannel(channelID: channelID,
                                             uID: CR.uID,
                                             creationDate: creationDate)
            } else if (result == false) {
                try await self.deleteCR(requestID: CR.requestID)
                
                try await self.deleteRU(uID: CR.uID)
            }
            
#if DEBUG
            DataU.shared.handleSuccess(function: "ChannelDC.sendCRResult", info: "CRID: \(CR.requestID)")
#endif
        } catch {
#if DEBUG
            DataU.shared.handleFailure(function: "ChannelDC.sendCRResult", err: error)
#endif
            throw error
        }
    }
    
    func sendCD(channel: SChannel,
                RU: SRemoteUser,
                deletionID: String = UuID().uuidString,
                type: String = "clear",
                deletionDate: Date = DateU.shared.currDT) async throws {
        do {
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
                    SocketController.shared.clientSocket.emitWithAck("sendCD", ["uID": RU.uID,
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
                                                           toDeleteuIDs: [RU.uID],
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
                    try await self.deleteChannel(channelID: channel.channelID)
                    
                    try await MessageDC.shared.deleteChannelMessages(channelID: channel.channelID)
                    
                    if let _ = try? await self.fetchRULocally(uID: RU.uID) {
                        try await self.deleteRU(uID: RU.uID)
                    }
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
            
#if DEBUG
            DataU.shared.handleSuccess(function: "ChannelDC.sendCD", info: "channel: \(channel.channelID)")
#endif
        } catch {
#if DEBUG
            DataU.shared.handleFailure(function: "ChannelDC.sendCD", err: error)
#endif
            throw error
        }
    }
    
    func sendCDResult(deletionID: String,
                      uID: String,
                      date: Date = DateU.shared.currDT) async throws {
        
        do {
            guard SocketController.shared.connected else {
                throw DCError.serverDisconnected(func: "ChannelDC.sendCDResult")
            }
            
            guard UserDC.shared.userOnline else {
                throw DCError.userDisconnected(func: "ChannelDC.sendCDResult")
            }
            
            guard let originUser = UserDC.shared.userData else { throw DCError.nilError(func: "ChannelDC.sendCR", err: "userData is nil") }
            
            let jsonPacket = try DataU.shared.dictionaryToJSONData(["deletionID": deletionID,
                                                                    "uID": originUser.uID,
                                                                    "date": DateU.shared.stringFromDate(date, TimeZone(identifier: "UTC")!)])
            
            try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("sendCDResult", ["uID": uID,
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
            
#if DEBUG
            DataU.shared.handleSuccess(function: "ChannelDC.sendCDResult", info: "deletionID: \(deletionID)")
#endif
            
        } catch {
#if DEBUG
            DataU.shared.handleFailure(function: "ChannelDC.sendCDResult", err: error)
#endif
            
            throw error
        }
    }
    
    
    func resetChannels(deletionDate: Date = DateU.shared.currDT) async throws {
        
        do {
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
                if channel.lastMessageDate != nil {
                    deletionPackets.append(["channelID": channel.channelID,
                                            "uID": channel.uID,
                                            "deletionID": UuID().uuidString,
                                            "deletionDate": deletionDateS])
                }
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
                          let uID = deletionData["uID"],
                          let deletionID = deletionData["deletionID"] else { throw DCError.nilError(func: "resetChannels") }
                    
                    let RU = try await self.fetchRULocally(uID: uID)
                    
                    let SCD = try await self.clearChannelData(channelID: channelID,
                                                              RU: RU,
                                                              deletionID: deletionID,
                                                              deletionDate: deletionDate,
                                                              isOrigin: true)
                    
                    self.syncCD(CD: SCD)
                    
#if DEBUG
                    DataU.shared.handleSuccess(function: "ChannelDC.resetChannels", info: "cleared channelID: \(channelID)")
#endif
                } catch {
#if DEBUG
                    DataU.shared.handleFailure(function: "ChannelDC.resetChannels", err: error, info: "channelID: \(String(describing: deletionData["channelID"]))")
#endif
                }
            }
            
#if DEBUG
            DataU.shared.handleSuccess(function: "ChannelDC.resetChannels")
#endif
            
        } catch {
#if DEBUG
            DataU.shared.handleFailure(function: "ChannelDC.resetChannels", err: error)
#endif
            
            throw error
        }
    }
}
