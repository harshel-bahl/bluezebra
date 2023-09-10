//
//  ChannelDC+Handlers.swift
//  bluezebra
//
//  Created by Harshel Bahl on 19/04/2023.
//

import Foundation
import SocketIO

extension ChannelDC {
    
    
    /// Socket Handlers
    ///
    
    func addSocketHandlers() {
        self.userOnlineHandler()
        self.userDisconnectedHandler()
        self.receivedCRHandler()
//        self.receivedCRResultHandler()
//        self.receivedCDHandler()
//        self.receivedCDResultHandler()
//        self.deleteUserTraceHandler()
    }
    
    
    /// Event Handlers
    ///
    
    func userOnlineHandler() {
        SocketController.shared.clientSocket.on("userOnline") { [weak self] (data, ack) in
            
            log.info(message: "userOnline triggered", event: "userOnline")
            
            self?.userOnline(data: data, ack: ack)
        }
    }
    
    func userDisconnectedHandler() {
        SocketController.shared.clientSocket.on("userDisconnected") { [weak self] (data, ack) in
            
            log.info(message: "userDisconnected triggered", event: "userDisconnected")
            
            self?.userDisconnected(data: data, ack: ack)
        }
    }
    
    func receivedCRHandler() {
        SocketController.shared.clientSocket.on("receivedCR") { [weak self] (data, ack) in
            
            log.info(message: "receivedCR triggered", event: "receivedCR")
            
            self?.receivedCR(data: data, ack: ack)
        }
    }
    
//    func receivedCRResultHandler() {
//        SocketController.shared.clientSocket.on("receivedCRResult") { [weak self] (data, ack) in
//
//            log.debug(message: "receivedCRResult triggered", event: "receivedCRResult")
//
//            self?.receivedCRResult(data: data, ack: ack)
//
//        }
//    }
//
//    func receivedCDHandler() {
//        SocketController.shared.clientSocket.on("receivedCD") { [weak self] (data, ack) in
//
//            log.debug(message: "receivedCD triggered", event: "receivedCD")
//
//            self?.receivedCD(data: data, ack: ack)
//        }
//    }
//
//    func receivedCDResultHandler() {
//        SocketController.shared.clientSocket.on("receivedCDResult") { [weak self] (data, ack) in
//
//            log.debug(message: "receivedCDResult triggered", event: "receivedCDResult")
//
//            self?.receivedCDResult(data: data, ack: ack)
//        }
//    }
//
//    func deleteUserTraceHandler() {
//        SocketController.shared.clientSocket.on("deleteUserTrace") { [weak self] (data, ack) in
//
//            log.debug(message: "deleteUserTrace triggered", event: "deleteUserTrace")
//
//            self?.deleteUserTrace(data: data, ack: ack)
//        }
//    }
    
    
    /// ChannelDC Event Handler Functions
    ///
    
    func userOnline(data: [Any],
                    ack: SocketAckEmitter) {
        do {
            guard let uIDString = data.first as? String else { throw DCError.jsonError(err: "data was nil or failed to convert to a String") }
            
            guard let uID = UUID(uuidString: uIDString) else { throw DCError.jsonError(err: "data failed to be convertred to a UUID") }
            
            if self.onlineUsers.keys.contains(uID) {
                DispatchQueue.main.async {
                    self.onlineUsers[uID] = true
                }
            }
        } catch {
            log.error(message: "failed to handle userOnline", event: "userOnline", error: error)
        }
        
    }
    
    func userDisconnected(data: [Any],
                          ack: SocketAckEmitter? = nil) {
        Task {
            do {
                guard let uIDString = data.first as? String else { throw DCError.jsonError(err: "data was nil or failed to convert to a String") }
                
                guard let uID = UUID(uuidString: uIDString) else { throw DCError.jsonError(err: "data failed to be convertred to a UUID") }
                
                if self.onlineUsers.keys.contains(uID) {
                    DispatchQueue.main.async {
                        self.onlineUsers[uID] = false
                    }
                }
                
                let SRU = try await DataPC.shared.backgroundPerformSync() {
                    let RUMO = try DataPC.shared.updateMO(entity: RemoteUser.self,
                                                          property: ["lastOnline"],
                                                          value: [DateU.shared.currDT],
                                                          predDicEqual: ["uID": uID])
                    return try RUMO.safeObject()
                }
                
                self.syncRU(RU: SRU)
                
                log.debug(message: "successfully handled userDisconnected", event: "userDisconnected")
            } catch {
                log.error(message: "failed to handle userDiconnected", event: "userDisconnected", error: error)
            }
        }
    }
    
    func receivedCR(data: [Any],
                    ack: SocketAckEmitter? = nil) {
        Task {
            do {
                guard let data = data.first as? Data else { throw DCError.typecastError(err: "data failed to typecast to Data or is nil") }
                
                let packet = try DataU.shared.jsonDecodeFromData(packet: CRP.self,
                                                                   data: data)
                
                let (SRU, SCR) = try await self.createCR(requestID: packet.requestID,
                                                         requestDate: packet.requestDate,
                                                         RU: packet.RU)
                
                self.syncRU(RU: SRU)
                self.syncCR(CR: SCR)
                
                if let ack = ack {
                    ack.with(NSNull())
                }
                
                log.debug(message: "successfully handled receivedCR", event: "receivedCR")
            } catch {
                log.error(message: "failed to handle receivedCR", event: "receivedCR", error: error)
                
                if let ack = ack {
                    ack.with(false)
                }
            }
        }
    }
    
//    func receivedCRResult(data: [Any],
//                          ack: SocketAckEmitter? = nil) {
//        Task {
//            do {
//                guard let data = data.first as? Data else { throw DCError.typecastError(err: "data failed to typecast to Data or is nil") }
//
//                let CRResultP = try DataU.shared.jsonDecodeFromData(packet: CRResultP.self,
//                                                                         data: data)
//
//                if CRResultP.result == true {
//
//                    let SChannel = try await DataPC.shared.backgroundPerformSync() {
//
//                        let CRMO = try DataPC.shared.fetchMO(entity: ChannelRequest.self,
//                                                             predDicEqual: ["requestID": CRResultP.requestID])
//
//                        let channelMO = try DataPC.shared.createChannel(channelID: CRResultP.channelID,
//                                                                        uID: CRMO.remoteUser.uID,
//                                                                        channelType: "RU",
//                                                                        creationDate: CRResultP.creationDate,
//                                                                        remoteUser: CRMO.remoteUser)
//
//                        try DataPC.shared.deleteMO(entity: ChannelRequest.self,
//                                                   predDicEqual: ["requestID": CRResultP.requestID])
//
//                        return try channelMO.safeObject()
//                    }
//
//                    if let ack = ack {
//                        ack.with(NSNull())
//                    }
//
//                    self.removeCR(requestID: requestID)
//                    self.syncChannel(channel: SChannel)
//
//                    log.debug(message: "successfully handled receivedCRResult", event: "receivedCRResult", info: "result: \(CRResultPacket.result)")
//                } else {
//
//                    try await DataPC.shared.backgroundPerformSync() {
//
//                        let CRMO = try DataPC.shared.fetchMO(entity: ChannelRequest.self,
//                                                             predDicEqual: ["requestID": requestID])
//
//                        try DataPC.shared.deleteMO(entity: RemoteUser.self,
//                                                   MODicEqual: ["channelRequest": CRMO])
//
//                        try DataPC.shared.deleteMO(entity: ChannelRequest.self,
//                                                   predDicEqual: ["requestID": requestID])
//                    }
//
//                    if let ack = ack {
//                        ack.with(NSNull())
//                    }
//
//                    self.removeCR(requestID: requestID)
//                    self.remove
//
//
//                    log.debug(message: "successfully handled receivedCRResult", event: "receivedCRResult", info: "result: \(CRResultPacket.result)")
//                }
//            } catch {
//                log.error(message: "failed to handle receivedCRResult", event: "receivedCRResult", error: error)
//
//                if let ack = ack {
//                    ack.with(false)
//                }
//            }
//        }
//    }
//
//    func receivedCD(data: [Any],
//                    ack: SocketAckEmitter? = nil) {
//        Task {
//            do {
//                guard let data = data.first as? Data else { throw DCError.typecastError( err: "data failed to typecast to Data or is nil") }
//
//                let CDPacket = try DataU.shared.jsonDecodeFromData(packet: CDPacket.self,
//                                                                   data: data)
//
//                guard let deletionID = UUID(uuidString: CDPacket.deletionID),
//                      let channelID = UUID(uuidString: CDPacket.channelID) else { throw DCError.jsonError(err: "failed to convert string to UUID") }
//
//                let deletionDate = try DateU.shared.dateFromString(CDPacket.deletionDate)
//
//                var RUID: UUID
//
//                if CDPacket.type == "clear" {
//
//                    let SCD = try await DataPC.shared.backgroundPerformSync() {
//
//                        let channelMO = try DataPC.shared.updateMO(entity: Channel.self,
//                                                                   property: ["lastMessageDate"],
//                                                                   value: [nil],
//                                                                   predDicEqual: ["channelID": channelID])
//
//                        RUID = channelMO.remoteUser.uID
//
//                        let CDMO = try DataPC.shared.createCD(deletionID: UUID(),
//                                                              channelType: "RU",
//                                                              deletionDate: deletionDate,
//                                                              type: "clear",
//                                                              name: channelMO.remoteUser.username,
//                                                              icon: channelMO.remoteUser.avatar,
//                                                              nUsers: 1,
//                                                              toDeleteUIDs: [channelMO.remoteUser.uID],
//                                                              isOrigin: false)
//
//                        return try CDMO.safeObject()
//                    }
//
//                        try await MessageDC.shared.clearChannelMessages(channelID: channelID)
//
//                    self.syncCD(CD: SCD)
//
//                } else if CDPacket.type == "delete" {
//
//                    self.removeChannel(channelID: channelID)
//
//                    let SCD = try await DataPC.shared.backgroundPerformSync() {
//
//                        let channelMO = try DataPC.shared.fetchMO(entity: Channel.self,
//                                                                  predDicEqual: ["channelID": channelID])
//
//                        RUID = channelMO.remoteUser.uID
//
//                        let CDMO = try DataPC.shared.createCD(deletionID: UUID(),
//                                                              channelType: "RU",
//                                                              deletionDate: deletionDate,
//                                                              type: "delete",
//                                                              name: channelMO.remoteUser.username,
//                                                              icon: channelMO.remoteUser.avatar,
//                                                              nUsers: 1,
//                                                              toDeleteUIDs: [channelMO.remoteUser.uID],
//                                                              isOrigin: false)
//
//                        try DataPC.shared.deleteMO(entity: Channel.self,
//                                                   predDicEqual: ["channelID": channelID])
//                        self.removeChannel(channelID: channelID)
//
//                        try DataPC.shared.deleteMO(entity: RemoteUser.self,
//                                                   predDicEqual: ["uID": channelMO.remoteUser.uID])
//                        self.removeRU(uID: RUID)
//
//                        return try CDMO.safeObject()
//                    }
//
//                    try await MessageDC.shared.deleteChannelMessages(channelID: CDPacket.channelID)
//
//                    self.syncCD(CD: SCD)
//                }
//
//                if let ack = ack {
//                    ack.with(NSNull())
//                }
//
//                log.debug(message: "successfully handled receivedCD", event: "receivedCD")
//
//                try? await self.sendCDResult(deletionID: CDPacket.deletionID,
//                                             uID: RUID)
//
//            } catch {
//                log.error(message: "failed to handle receivedCD", event: "receivedCD", error: error)
//
//                if let ack = ack {
//                    ack.with(false)
//                }
//            }
//        }
//    }
//
//    func receivedCDResult(data: [Any],
//                          ack: SocketAckEmitter? = nil) {
//        Task {
//            do {
//                guard let data = data.first as? Data else { throw DCError.typecastError( err: "data failed to typecast to Data or is nil") }
//
//                let CDResult = try DataU.shared.jsonDataToDictionary(data)
//
//                guard let deletionID = CDResult["deletionID"] as? String,
//                      let uID = CDResult["uID"] as? String,
//                      let date = CDResult["date"] as? String else { throw DCError.jsonError() }
//
//                let remoteDeletedDate = try DateU.shared.dateFromString(date)
//
//                let SCD = try await DataPC.shared.fetchSMO(entity: ChannelDeletion.self,
//                                                           predDicEqual: ["deletionID": deletionID])
//
//                if var toDeleteuIDs = SCD.toDeleteuIDs?.components(separatedBy: ",") {
//                    toDeleteuIDs = toDeleteuIDs.filter { $0 != uID }
//                    let uIDs = toDeleteuIDs.joined(separator: ",")
//
//                    if toDeleteuIDs.isEmpty {
//                        let updatedSCD = try await DataPC.shared.updateMO(entity: ChannelDeletion.self,
//                                                                          property: ["toDeleteuIDs", "remoteDeletedDate"],
//                                                                          value: [uIDs, remoteDeletedDate],
//                                                                          predDicEqual: ["deletionID": deletionID])
//                        self.removeCD(deletionID: deletionID)
//                        self.syncCD(CD: updatedSCD)
//                    } else {
//                        let updatedSCD = try await DataPC.shared.updateMO(entity: ChannelDeletion.self,
//                                                                          property: ["toDeleteuIDs"],
//                                                                          value: [uIDs],
//                                                                          predDicEqual: ["deletionID": deletionID])
//                        self.removeCD(deletionID: deletionID)
//                        self.syncCD(CD: updatedSCD)
//                    }
//
//                    if let ack = ack {
//                        ack.with(NSNull())
//                    }
//
//                } else {
//                    throw DCError.nilError()
//                }
//            } catch {
//
//                if let ack = ack {
//                    ack.with(false)
//                }
//            }
//        }
//    }
//
//    func deleteUserTrace(data: [Any],
//                         ack: SocketAckEmitter? = nil) {
//        Task {
//            do {
//                guard let data = data.first as? Data else { throw DCError.typecastError( err: "data failed to typecast to Data or is nil") }
//
//                let deletionData = try DataU.shared.jsonDataToDictionary(data)
//
//                guard let uID = deletionData["uID"] as? String else { throw DCError.jsonError() }
//
//                try await self.deleteUserTrace(uID: uID)
//
//                if let ack = ack {
//                    ack.with(NSNull())
//                }
//
//            } catch {
//
//                if let ack = ack {
//                    ack.with(false)
//                }
//            }
//        }
//    }
}
