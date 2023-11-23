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
    
    func fetchRUP(
        uID: UUID,
        checkuID: Bool = true
    ) async throws -> RUP {
        do {
            try checkSocketConnected()
            
            try checkUserConnected()
            
            if checkuID {
                guard uID != UserDC.shared.userdata?.uID else { throw DCError.invalidRequest(err: "cannot check for own uID") }
            }
            
            let packet = try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("fetchRUP", uID.uuidString)
                    .timingOut(after: 1, callback: { data in
                        do {
                            if let queryStatus = data.first as? String,
                               queryStatus == SocketAckStatus.noAck {
                                throw DCError.serverTimeOut()
                            } else if let queryStatus = data.first as? String {
                                throw DCError.serverFailure(err: queryStatus)
                            } else if let _ = data.first as? NSNull,
                                      data.indices.contains(1) {
                                continuation.resume(returning: data[1])
                            } else {
                                throw DCError.serverFailure()
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    })
            }
            
            let RUPacket = try DataU.shared.jsonDecodeFromObject(packet: RUP.self,
                                                                 dataObject: packet)
            
            log.debug(message: "successfully fetched RUP", function: "ChannelDC.fetchRUP", event: "fetchRUP")
            
            return RUPacket
        } catch {
            log.error(message: "failed to fetch RUP", function: "ChannelDC.fetchRUP", event: "fetchRUP", error: error)
            throw error
        }
    }
    
    
    func fetchRUPs(
        username: String,
        checkUsername: Bool = true
    ) async throws -> [RUP] {
        do {
            try checkSocketConnected()
            
            try checkUserConnected()
            
            if checkUsername {
                guard username != UserDC.shared.userdata?.username else { throw DCError.invalidRequest(err: "cannot check for own username") }
            }
            
            let packets = try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("fetchRUsByUsername", ["username": username])
                    .timingOut(after: 1, callback: { data in
                        
                        do {
                            if let queryStatus = data.first as? String,
                               queryStatus == SocketAckStatus.noAck {
                                throw DCError.serverTimeOut()
                            } else if let queryStatus = data.first as? String {
                                throw DCError.serverFailure(err: queryStatus)
                            } else if let _ = data.first as? NSNull,
                                      data.indices.contains(1),
                                      let packets = data[1] as? Data {
                                continuation.resume(returning: packets)
                            } else {
                                throw DCError.serverFailure()
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    })
            }
            
            let RUPackets = try DataU.shared.jsonDecodeFromData(packet: [RUP].self,
                                                                data: packets)
            
            log.debug(message: "successfully fetched RUPs", function: "ChannelDC.fetchRUPs", event: "fetchRUPsByUsername")
            
            return RUPackets
        } catch {
            log.error(message: "failed to fetch RUPs", function: "ChannelDC.fetchRUPs", event: "fetchRUPsByUsername", error: error)
            throw error
        }
    }
    
    func fetchCRP(
        requestID: UUID
    ) async throws -> CRP {
        do {
            try checkSocketConnected()
            
            try checkUserConnected()
            
            let packet = try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("fetchCRP", ["requestID": requestID])
                    .timingOut(after: 1, callback: { data in
                        
                        do {
                            if let queryStatus = data.first as? String,
                               queryStatus == SocketAckStatus.noAck {
                                throw DCError.serverTimeOut()
                            } else if let queryStatus = data.first as? String {
                                throw DCError.serverFailure(err: queryStatus)
                            } else if let _ = data.first as? NSNull,
                                      data.indices.contains(1),
                                      let packet = data[1] as? Data {
                                continuation.resume(returning: packet)
                            } else {
                                throw DCError.serverFailure()
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    })
            }
            
            let CRP = try DataU.shared.jsonDecodeFromData(packet: CRP.self,
                                                          data: packet)
            
            log.debug(message: "successfully fetched CRP", function: "ChannelDC.fetchCRP", event: "fetchCRP")
            
            return CRP
        } catch {
            log.error(message: "failed to fetch CRP", function: "ChannelDC.fetchCRP", event: "fetchCRP", error: error)
            throw error
        }
    }
    
    func fetchCRPs(requestIDs: [String]? = nil) async throws -> [CRP] {
        do {
            try checkSocketConnected()
            
            try checkUserConnected()
            
            let packets = try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("fetchCRPs", ["requestIDs": requestIDs])
                    .timingOut(after: 1, callback: { data in
                        
                        do {
                            if let queryStatus = data.first as? String,
                               queryStatus == SocketAckStatus.noAck {
                                throw DCError.serverTimeOut()
                            } else if let queryStatus = data.first as? String {
                                throw DCError.serverFailure(err: queryStatus)
                            } else if let _ = data.first as? NSNull,
                                      data.indices.contains(1),
                                      let packets = data[1] as? Data {
                                continuation.resume(returning: packets)
                            } else {
                                throw DCError.serverFailure()
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    })
            }
            
            let CRPs = try DataU.shared.jsonDecodeFromData(packet: [CRP].self,
                                                           data: packets)
            
            log.debug(message: "successfully fetched CRP", function: "ChannelDC.fetchCRP", event: "fetchCRP")
            
            return CRPs
        } catch {
            log.error(message: "failed to fetch CRP", function: "ChannelDC.fetchCRP", event: "fetchCRP", error: error)
            throw error
        }
    }
    
    func fetchCRRequestIDs(limit: Int? = nil) async throws -> [UUID] {
        do {
            try checkSocketConnected()
            
            try checkUserConnected()
            
            let packet = try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("fetchCRRequestIDs", ["limit": limit])
                    .timingOut(after: 1, callback: { data in
                        
                        do {
                            if let queryStatus = data.first as? String,
                               queryStatus == SocketAckStatus.noAck {
                                throw DCError.serverTimeOut()
                            } else if let queryStatus = data.first as? String {
                                throw DCError.serverFailure(err: queryStatus)
                            } else if let _ = data.first as? NSNull,
                                      data.indices.contains(1),
                                      let packet = data[1] as? Data {
                                continuation.resume(returning: packet)
                            } else {
                                throw DCError.serverFailure()
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    })
            }
            
            let requestsData = try DataU.shared.jsonDataToArray(packet)
            
            guard let requestIDs = requestsData as? [String] else { throw DCError.typecastError(err: "failed to typecast to [String]") }
            
            let requestUUIDs = requestIDs.compactMap() { return UUID(uuidString: $0) }
            
            log.debug(message: "successfully fetched CR requestIDs", function: "ChannelDC.fetchCRRequestIDs", event: "fetchCRRequestIDs")
            
            return requestUUIDs
        } catch {
            log.error(message: "failed to fetch CR requestIDs", function: "ChannelDC.fetchCRRequestIDs", event: "fetchCRRequestIDs", error: error)
            throw error
        }
    }
    
    func deleteCRs(
        requestIDs: [String]
    ) async throws {
        do {
            try checkSocketConnected()
            
            try checkUserConnected()
            
            try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("deleteCRs", requestIDs)
                    .timingOut(after: 1, callback: { data in
                        
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
                    })
            }
            
            log.info(message: "deleted CRs in server", function: "ChannelDC.deleteCRs", event: "deleteCRs", info: "requestIDs: \(requestIDs)")
        } catch {
            log.error(message: "failed to delete CRs", function: "ChannelDC.deleteCRs", event: "deleteCRs", error: error)
            throw error
        }
    }
    
    func fetchRUChannelP(
        channelID: UUID
    ) async throws -> RUChannelP {
        do {
            try checkSocketConnected()
            
            try checkUserConnected()
            
            let packet = try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("fetchRUChannelP", ["channelID": channelID.uuidString])
                    .timingOut(after: 1, callback: { data in
                        
                        do {
                            if let queryStatus = data.first as? String,
                               queryStatus == SocketAckStatus.noAck {
                                throw DCError.serverTimeOut()
                            } else if let queryStatus = data.first as? String {
                                throw DCError.serverFailure(err: queryStatus)
                            } else if let _ = data.first as? NSNull,
                                      data.indices.contains(1),
                                      let packet = data[1] as? Data {
                                continuation.resume(returning: packet)
                            } else {
                                throw DCError.serverFailure()
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    })
            }
            
            let RUChannelP = try DataU.shared.jsonDecodeFromData(packet: RUChannelP.self,
                                                                 data: packet)
            
            log.info(message: "fetched RUChannelP", function: "ChannelDC.fetchRUChannelP", event: "fetchRUChannelP", info: "channelID: \(channelID.uuidString)")
            
            return RUChannelP
            
        } catch {
            log.error(message: "failed to fetch RUChannelP", function: "ChannelDC.fetchRUChannelP", event: "fetchRUChannelP", error: error)
            throw error
        }
    }
    
    func fetchRUChannelPs(
        channelIDs: [String]? = nil
    ) async throws -> [RUChannelP] {
        do {
            try checkSocketConnected()
            
            try checkUserConnected()
            
            let packets = try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("fetchRUChannelPs", ["channelIDs": channelIDs])
                    .timingOut(after: 1, callback: { data in
                        
                        do {
                            if let queryStatus = data.first as? String,
                               queryStatus == SocketAckStatus.noAck {
                                throw DCError.serverTimeOut()
                            } else if let queryStatus = data.first as? String {
                                throw DCError.serverFailure(err: queryStatus)
                            } else if let _ = data.first as? NSNull,
                                      data.indices.contains(1),
                                      let packets = data[1] as? Data {
                                continuation.resume(returning: packets)
                            } else {
                                throw DCError.serverFailure()
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    })
            }
            
            let RUChannelPs = try DataU.shared.jsonDecodeFromData(packet: [RUChannelP].self,
                                                                  data: packets)
            
            log.info(message: "fetched RUChannelPs", function: "ChannelDC.fetchRUChannelPs", event: "fetchRUChannelPs", info: "channelIDs: \(String(describing: channelIDs))")
            
            return RUChannelPs
            
        } catch {
            log.error(message: "failed to fetch RUChannelPs", function: "ChannelDC.fetchRUChannelPs", event: "fetchRUChannelPs", error: error)
            throw error
        }
    }
    
    func checkRUsOnline(
        uIDs: [String]
    ) async {
        do {
            try checkSocketConnected()
            
            try checkUserConnected()

            let packet = try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("checkRUsOnline", uIDs)
                    .timingOut(after: 1, callback: { data in
                        do {
                            if let queryStatus = data.first as? String,
                               queryStatus == SocketAckStatus.noAck {
                                throw DCError.serverTimeOut()
                            } else if let queryStatus = data.first as? String {
                                throw DCError.serverFailure(err: queryStatus)
                            } else if let _ = data.first as? NSNull,
                                      data.indices.contains(1) {
                                continuation.resume(returning: data[1])
                            } else {
                                throw DCError.serverFailure()
                            }
                        } catch {
                            continuation.resume(throwing: error)
                        }
                    })
            }

            guard let packet = packet as? [String: Any] else { throw DCError.typecastError(err: "couldn't cast result to [String: Any]") }

            var RUStatusUpdated = 0

            for uIDS in packet.keys {
                do {
                    guard let uID = UUID(uuidString: uIDS) else { throw DCError.jsonError(err: "failed to convert string to UUID") }
                    
                    if let userStatus = packet[uIDS] as? Bool,
                       userStatus == true {
                        
                        DispatchQueue.main.async {
                            self.onlineUsers[uID] = true
                        }
                        
                    } else if let lastOnlineS = packet[uIDS] as? String {
                        
                        DispatchQueue.main.async {
                            self.onlineUsers[uID] = false
                        }
                        
                        let lastOnline = try DateU.shared.dateFromISOString(lastOnlineS)
                        
                        let SRU = try await DataPC.shared.backgroundPerformSync() {
                            let RUMO = try DataPC.shared.updateMO(entity: RemoteUser.self,
                                                                  property: ["lastOnline"],
                                                                  value: [lastOnline],
                                                                  predDicEqual: ["uID": uID])
                            return try RUMO.safeObject()
                        }
                        
                        self.syncRU(RU: SRU)
                    }
                    
                    RUStatusUpdated += 1
                    
                    log.debug(message: "updated lastOnline for RU", function: "ChannelDC.checkRUsOnline", event: "checkRUsOnline", info: "RUID: \(uIDS)")
                } catch {
                    log.debug(message: "failed to update lastOnline for RU", function: "ChannelDC.checkRUsOnline", event: "checkRUsOnline", info: "RUID: \(uIDS)")
                }
            }
            
            log.info(message: "checked RUs online", function: "ChannelDC.checkRUsOnline", event: "checkRUsOnline", info: "updatedRUs: \(RUStatusUpdated)")
        } catch {
            log.error(message: "failed to check RUs Online", function: "ChannelDC.checkRUsOnline", event: "checkRUsOnline")
        }
    }
    
    /// sendCR:
    /// - Failure event is created first in local persistence in case of A going offline suddenly so that event can be emitted on next startup
    /// - Sends request to server and awaits ack
    ///     - If ack is null, local objects are created
    ///     - If ack is errored or timeOut, local objects aren't created
    /// - If local persistence errors, then a sendCRFailure is emitted after all objects are deleted and the corresponding failure event is removed from local persistence on successful emit of failure event
    func sendCR(RU: RUP,
                requestID: UUID = UUID(),
                requestDate: Date = DateU.shared.currDT,
                checkuID: Bool = true) async throws {
        do {
            try checkSocketConnected()
            
            try checkUserConnected()
            
            if checkuID {
                guard RU.uID != UserDC.shared.userdata?.uID else { throw DCError.invalidRequest(err: "cannot send CR to self") }
            }
            
            let packet = try DataU.shared.dictionaryToJSONData(["requestID": requestID.uuidString,
                                                                "requestDate": DateU.shared.stringFromDate(requestDate)])
            
            try await withCheckedThrowingContinuation() { continuation in
                SocketController.shared.clientSocket.emitWithAck("sendCR", ["uID": RU.uID.uuidString,
                                                                            "packet": packet] as [String : Any])
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
            
            let (SRU, SCR) = try await self.createCR(requestID: requestID,
                                                     requestDate: requestDate,
                                                     RU: RU)
            self.syncRU(RU: SRU)
            self.syncCR(CR: SCR)
            
            log.info(message: "successfully sent CR", function: "ChannelDC.sendCR", event: "sendCR", info: "RUID: \(RU.uID)")
            
        } catch {
            log.debug(message: "failed to send CR", function: "ChannelDC.sendCR", event: "sendCR", info: "RUID: \(RU.uID)")
            throw error
        }
    }
    
    /// sendCRResult:
    /// -
//    func sendCRResult(CR: SChannelRequest,
//                      result: Bool,
//                      channelID: String = UuID().uuidString,
//                      creationDate: Date = DateU.shared.currDT) async throws {
//
//        do {
//            guard SocketController.shared.connected else {
//                throw DCError.serverDisconnected(func: "ChannelDC.sendCRResult")
//            }
//
//            guard UserDC.shared.userOnline else {
//                throw DCError.userDisconnected(func: "ChannelDC.sendCRResult")
//            }
//
//            let jsonPacket = try DataU.shared.dictionaryToJSONData(["requestID": CR.requestID,
//                                                                    "result": result,
//                                                                    "channelID": channelID,
//                                                                    "creationDate": DateU.shared.stringFromDate(creationDate, TimeZone(identifier: "UTC")!)])
//
//            try await withCheckedThrowingContinuation() { continuation in
//                SocketController.shared.clientSocket.emitWithAck("sendCRResult", ["uID": CR.uID,
//                                                                                  "packet": jsonPacket] as [String : Any])
//                .timingOut(after: 1) { data in
//                    do {
//                        if let queryStatus = data.first as? String,
//                           queryStatus == SocketAckStatus.noAck {
//                            throw DCError.serverTimeOut(func: "ChannelDC.sendCRResult")
//                        } else if let queryStatus = data.first as? String {
//                            throw DCError.serverFailure(func: "ChannelDC.sendCRResult", err: queryStatus)
//                        } else if let _ = data.first as? NSNull {
//                            continuation.resume(returning: ())
//                        } else {
//                            throw DCError.serverFailure(func: "ChannelDC.sendCRResult")
//                        }
//                    } catch {
//                        continuation.resume(throwing: error)
//                    }
//                }
//            }
//
//            if (result == true) {
//                try await self.deleteCR(requestID: CR.requestID)
//
//                try await self.createChannel(channelID: channelID,
//                                             uID: CR.uID,
//                                             creationDate: creationDate)
//            } else if (result == false) {
//                try await self.deleteCR(requestID: CR.requestID)
//
//                try await self.deleteRU(uID: CR.uID)
//            }
//
//#if DEBUG
//            DataU.shared.handleSuccess(function: "ChannelDC.sendCRResult", info: "CRID: \(CR.requestID)")
//#endif
//        } catch {
//#if DEBUG
//            DataU.shared.handleFailure(function: "ChannelDC.sendCRResult", err: error)
//#endif
//            throw error
//        }
//    }
//
//    func sendCD(channel: SChannel,
//                RU: SRemoteUser,
//                deletionID: String = UuID().uuidString,
//                type: String = "clear",
//                deletionDate: Date = DateU.shared.currDT) async throws {
//        do {
//            guard SocketController.shared.connected else {
//                throw DCError.serverDisconnected(func: "ChannelDC.sendCD")
//            }
//
//            guard UserDC.shared.userOnline else {
//                throw DCError.userDisconnected(func: "ChannelDC.sendCD")
//            }
//
//            let jsonPacket = try DataU.shared.dictionaryToJSONData(["deletionID": deletionID,
//                                                                    "deletionDate": DateU.shared.stringFromDate(deletionDate, TimeZone(identifier: "UTC")!),
//                                                                    "type": type,
//                                                                    "channelID": channel.channelID])
//            do {
//                if type == "clear" {
//                    MessageDC.shared.channelMessages.removeValue(forKey: channel.channelID)
//                } else if type == "delete" {
//                    self.removeChannel(channelID: channel.channelID)
//                }
//
//                try await withCheckedThrowingContinuation() { continuation in
//                    SocketController.shared.clientSocket.emitWithAck("sendCD", ["uID": RU.uID,
//                                                                                "packet": jsonPacket] as [String : Any])
//                    .timingOut(after: 1) { data in
//                        do {
//                            if let queryStatus = data.first as? String,
//                               queryStatus == SocketAckStatus.noAck {
//                                throw DCError.serverTimeOut(func: "ChannelDC.sendCD")
//                            } else if let queryStatus = data.first as? String {
//                                throw DCError.serverFailure(func: "ChannelDC.sendCD", err: queryStatus)
//                            } else if let _ = data.first as? NSNull {
//                                continuation.resume(returning: ())
//                            } else {
//                                throw DCError.serverFailure(func: "ChannelDC.sendCD")
//                            }
//                        } catch {
//                            continuation.resume(throwing: error)
//                        }
//                    }
//                }
//
//                let SCD = try await DataPC.shared.createCD(deletionID: deletionID,
//                                                           channelType: "RU",
//                                                           deletionDate: deletionDate,
//                                                           type: type,
//                                                           name: RU.username,
//                                                           icon: RU.avatar,
//                                                           nUsers: 1,
//                                                           toDeleteuIDs: [RU.uID],
//                                                           isOrigin: true)
//                self.syncCD(CD: SCD)
//
//                if type == "clear" {
//                    let SChannel = try await DataPC.shared.updateMO(entity: Channel.self,
//                                                                    predicateProperty: "channelID",
//                                                                    predicateValue: channel.channelID,
//                                                                    property: ["lastMessageDate"],
//                                                                    value: [nil])
//                    self.syncChannel(channel: SChannel)
//
//                    try await MessageDC.shared.clearChannelMessages(channelID: channel.channelID)
//                } else if type == "delete" {
//                    try await self.deleteChannel(channelID: channel.channelID)
//
//                    try await MessageDC.shared.deleteChannelMessages(channelID: channel.channelID)
//
//                    if let _ = try? await self.fetchRULocally(uID: RU.uID) {
//                        try await self.deleteRU(uID: RU.uID)
//                    }
//                }
//            } catch {
//                if type == "clear" {
//                    try? await MessageDC.shared.syncChannel(channelID: channel.channelID)
//                } else if type == "delete" {
//                    if let SChannel = try? await DataPC.shared.fetchSMO(entity: Channel.self,
//                                                                        predicateProperty: "channelID",
//                                                                        predicateValue: channel.channelID) {
//                        self.syncChannel(channel: SChannel)
//                    }
//                }
//
//                throw error
//            }
//
//#if DEBUG
//            DataU.shared.handleSuccess(function: "ChannelDC.sendCD", info: "channel: \(channel.channelID)")
//#endif
//        } catch {
//#if DEBUG
//            DataU.shared.handleFailure(function: "ChannelDC.sendCD", err: error)
//#endif
//            throw error
//        }
//    }
//
//    func sendCDResult(deletionID: String,
//                      uID: String,
//                      date: Date = DateU.shared.currDT) async throws {
//
//        do {
//            guard SocketController.shared.connected else {
//                throw DCError.serverDisconnected(func: "ChannelDC.sendCDResult")
//            }
//
//            guard UserDC.shared.userOnline else {
//                throw DCError.userDisconnected(func: "ChannelDC.sendCDResult")
//            }
//
//            guard let originUser = UserDC.shared.userData else { throw DCError.nilError(func: "ChannelDC.sendCR", err: "userData is nil") }
//
//            let jsonPacket = try DataU.shared.dictionaryToJSONData(["deletionID": deletionID,
//                                                                    "uID": originUser.uID,
//                                                                    "date": DateU.shared.stringFromDate(date, TimeZone(identifier: "UTC")!)])
//
//            try await withCheckedThrowingContinuation() { continuation in
//                SocketController.shared.clientSocket.emitWithAck("sendCDResult", ["uID": uID,
//                                                                                  "packet": jsonPacket] as [String : Any])
//                .timingOut(after: 1) { data in
//                    do {
//                        if let queryStatus = data.first as? String,
//                           queryStatus == SocketAckStatus.noAck {
//                            throw DCError.serverTimeOut(func: "ChannelDC.resetChannels")
//                        } else if let queryStatus = data.first as? String {
//                            throw DCError.serverFailure(func: "ChannelDC.resetChannels", err: queryStatus)
//                        } else if let _ = data.first as? NSNull {
//                            continuation.resume(returning: ())
//                        } else {
//                            throw DCError.serverFailure(func: "ChannelDC.resetChannels")
//                        }
//                    } catch {
//                        continuation.resume(throwing: error)
//                    }
//                }
//            }
//
//#if DEBUG
//            DataU.shared.handleSuccess(function: "ChannelDC.sendCDResult", info: "deletionID: \(deletionID)")
//#endif
//
//        } catch {
//#if DEBUG
//            DataU.shared.handleFailure(function: "ChannelDC.sendCDResult", err: error)
//#endif
//
//            throw error
//        }
//    }
//
//
//    func resetChannels(deletionDate: Date = DateU.shared.currDT) async throws {
//
//        do {
//            guard SocketController.shared.connected else {
//                throw DCError.serverDisconnected(func: "ChannelDC.resetChannels")
//            }
//
//            guard UserDC.shared.userOnline else {
//                throw DCError.userDisconnected(func: "ChannelDC.resetChannels")
//            }
//
//            let predicate = NSPredicate(format: "channelID != %@", argumentArray: ["personal"])
//
//            let RUChannels = try await DataPC.shared.fetchSMOs(entity: Channel.self,
//                                                               customPredicate: predicate)
//
//            let deletionDateS = DateU.shared.stringFromDate(deletionDate, TimeZone(identifier: "UTC")!)
//
//            var deletionPackets = [[String: String]]()
//
//            for channel in RUChannels {
//                if channel.lastMessageDate != nil {
//                    deletionPackets.append(["channelID": channel.channelID,
//                                            "uID": channel.uID,
//                                            "deletionID": UuID().uuidString,
//                                            "deletionDate": deletionDateS])
//                }
//            }
//
//            let jsonPacket = try DataU.shared.arrayToJSONData(deletionPackets)
//
//            try await withCheckedThrowingContinuation() { continuation in
//                SocketController.shared.clientSocket.emitWithAck("resetChannels", ["packet": jsonPacket] as [String : Any])
//                    .timingOut(after: 1) { data in
//                        do {
//                            if let queryStatus = data.first as? String,
//                               queryStatus == SocketAckStatus.noAck {
//                                throw DCError.serverTimeOut(func: "ChannelDC.resetChannels")
//                            } else if let queryStatus = data.first as? String {
//                                throw DCError.serverFailure(func: "ChannelDC.resetChannels", err: queryStatus)
//                            } else if let _ = data.first as? NSNull {
//                                continuation.resume(returning: ())
//                            } else {
//                                throw DCError.serverFailure(func: "ChannelDC.resetChannels")
//                            }
//                        } catch {
//                            continuation.resume(throwing: error)
//                        }
//                    }
//            }
//
//            for deletionData in deletionPackets {
//                do {
//                    guard let channelID = deletionData["channelID"],
//                          let uID = deletionData["uID"],
//                          let deletionID = deletionData["deletionID"] else { throw DCError.nilError(func: "resetChannels") }
//
//                    let RU = try await self.fetchRULocally(uID: uID)
//
//                    let SCD = try await self.clearChannelData(channelID: channelID,
//                                                              RU: RU,
//                                                              deletionID: deletionID,
//                                                              deletionDate: deletionDate,
//                                                              isOrigin: true)
//
//                    self.syncCD(CD: SCD)
//
//#if DEBUG
//                    DataU.shared.handleSuccess(function: "ChannelDC.resetChannels", info: "cleared channelID: \(channelID)")
//#endif
//                } catch {
//#if DEBUG
//                    DataU.shared.handleFailure(function: "ChannelDC.resetChannels", err: error, info: "channelID: \(String(describing: deletionData["channelID"]))")
//#endif
//                }
//            }
//
//#if DEBUG
//            DataU.shared.handleSuccess(function: "ChannelDC.resetChannels")
//#endif
//
//        } catch {
//#if DEBUG
//            DataU.shared.handleFailure(function: "ChannelDC.resetChannels", err: error)
//#endif
//
//            throw error
//        }
//    }
}
