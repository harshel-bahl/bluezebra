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
        self.receivedCRResultHandler()
        self.receivedCDHandler()
        self.receivedCDResultHandler()
        self.deleteUserTraceHandler()
    }
    
    /// Event Handlers
    ///
    
    func userOnlineHandler() {
        SocketController.shared.clientSocket.on("userOnline") { [weak self] (data, ack) in
            
            log.info(message: "userOnline triggered", event: "ChannelDC.userOnline")
            
            self?.userOnline(data: data, ack: ack)
        }
    }
    
    func userDisconnectedHandler() {
        SocketController.shared.clientSocket.on("userDisconnected") { [weak self] (data, ack) in
            
            log.info(message: "userDisconnected triggered", event: "ChannelDC.userDisconnected")
            
            self?.userDisconnected(data: data, ack: ack)
        }
    }
    
    func receivedCRHandler() {
        SocketController.shared.clientSocket.on("receivedCR") { [weak self] (data, ack) in
            
            log.info(message: "receivedCR triggered", event: "ChannelDC.receivedCR")
            
            self?.receivedCR(data: data, ack: ack)
        }
    }
    
    func receivedCRResultHandler() {
        SocketController.shared.clientSocket.on("receivedCRResult") { [weak self] (data, ack) in
            
            log.debug(message: "receivedCRResult triggered", event: "receivedCRResult")
            
            self?.receivedCRResult(data: data, ack: ack)
            
        }
    }
    
    func receivedCDHandler() {
        SocketController.shared.clientSocket.on("receivedCD") { [weak self] (data, ack) in
            
            log.debug(message: "receivedCD triggered", event: "receivedCD")
         
            self?.receivedCD(data: data, ack: ack)
        }
    }
    
    func receivedCDResultHandler() {
        SocketController.shared.clientSocket.on("receivedCDResult") { [weak self] (data, ack) in
            
            log.debug(message: "receivedCDResult triggered", event: "receivedCDResult")
         
            self?.receivedCDResult(data: data, ack: ack)
        }
    }
    
    func deleteUserTraceHandler() {
        SocketController.shared.clientSocket.on("deleteUserTrace") { [weak self] (data, ack) in
            
            log.debug(message: "deleteUserTrace triggered", event: "deleteUserTrace")
         
            self?.deleteUserTrace(data: data, ack: ack)
        }
    }
    
    
    
    
    /// Event Handler Functions
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
            log.error(message: "failed to handle userOnline", event: "ChannelDC.userOnline", error: error)
        }
        
    }
    
    func userDisconnected(data: [Any],
                          ack: SocketAckEmitter) {
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
                                                          predObject: ["uID": uID])
                    return try RUMO.safeObject()
                }
                
                self.syncRU(RU: SRU)
                
                log.debug(message: "successfully handled userDisconnected", event: "ChannelDC.userDisconnected")
            } catch {
                log.error(message: "failed to handle userDiconnected", event: "ChannelDC.userDisconnected", error: error)
            }
        }
    }
    
    func receivedCR(data: [Any],
                    ack: SocketAckEmitter) {
        Task {
            do {
                guard let data = data.first as? Data else { throw DCError.typecastError( err: "data failed to typecast to Data or is nil") }
                
                let CRPacket = try DataU.shared.jsonDecodeFromData(packet: CRPacket.self,
                                                                   data: data)
                
                let date = try DateU.shared.dateFromString(CRPacket.date)
                let RUCreationDate = try DateU.shared.dateFromStringTZ(CRPacket.RU.creationDate)
                
                let RULastOnline: Date?
                
                if let lastOnline = CRPacket.RU.lastOnline {
                    RULastOnline = try DateU.shared.dateFromStringTZ(lastOnline)
                } else {
                    RULastOnline = nil
                }
                
                guard let requestID = UUID(uuidString: CRPacket.requestID),
                      let uID = UUID(uuidString: CRPacket.RU.uID) else { throw DCError.jsonError(err: "requestID or uID failed to convert to UUID") }
                
                let (SRU, SCR) = try await DataPC.shared.backgroundPerformSync() {
                    let RUMO = try DataPC.shared.createRU(uID: uID,
                                                          username: CRPacket.RU.username,
                                                          avatar: CRPacket.RU.avatar,
                                                          creationDate: RUCreationDate)
                    
                    let CRMO = try DataPC.shared.createCR(requestID: requestID,
                                                          uID: uID,
                                                          date: date,
                                                          isSender: false,
                                                          remoteUser: RUMO)
                    
                    return (try RUMO.safeObject(), try CRMO.safeObject())
                }
                
                self.syncRU(RU: SRU)
                self.syncCR(CR: SCR)
                
                
                ack.with(NSNull())
                log.debug(message: "successfully handled receivedCR", event: "channelDC.receivedCR")
            } catch {
                log.error(message: "failed to handle receivedCR", event: "ChannelDC.receivedCR", error: error)
                ack.with(false)
            }
        }
    }
    
    func receivedCRResult(data: [Any],
                          ack: SocketAckEmitter) {
        Task {
            do {
                guard let data = data.first as? Data else { throw DCError.typecastError(err: "data failed to typecast to Data or is nil") }
                
                let CRResultPacket = try DataU.shared.jsonDecodeFromData(packet: CRResultPacket.self,
                                                                         data: data)
                
                guard let requestID = UUID(uuidString: CRResultPacket.requestID),
                      let channelID = UUID(uuidString: CRResultPacket.channelID) else { throw DCError.jsonError(err: "failed to convert string IDs to UUIDs") }
                
                let creationDate = try DateU.shared.dateFromString(CRResultPacket.creationDate)
                
                if CRResultPacket.result == true {
                    
                    let SChannel = try await DataPC.shared.backgroundPerformSync() {
                        
                        let CRMO = try DataPC.shared.fetchMO(entity: ChannelRequest.self,
                                                             predObject: ["requestID": requestID])
                        
                        let channelMO = try DataPC.shared.createChannel(channelID: channelID,
                                                                        uID: CRMO.remoteUser.uID,
                                                                        channelType: "RU",
                                                                        creationDate: creationDate,
                                                                        remoteUser: CRMO.remoteUser)
                        
                        try DataPC.shared.deleteMO(entity: ChannelRequest.self,
                                                   predObject: ["requestID": requestID])
                        
                        return try channelMO.safeObject()
                    }
                    
                    ack.with(NSNull())
                    
                    self.removeCR(requestID: requestID)
                    self.syncChannel(channel: SChannel)
                    
                    log.debug(message: "successfully handled receivedCRResult", event: "receivedCRResult", info: "result: \(CRResultPacket.result)")
                } else {
                    
                    try await DataPC.shared.backgroundPerformSync() {
                        
                        let CRMO = try DataPC.shared.fetchMO(entity: ChannelRequest.self,
                                                             predObject: ["requestID": requestID])
                        
                        try DataPC.shared.deleteMO(entity: RemoteUser.self,
                                                   predObject: ["channelRequest": CRMO])
                        
                        try DataPC.shared.deleteMO(entity: ChannelRequest.self,
                                                   predObject: ["requestID": requestID])
                    }
                    
                    ack.with(NSNull())
                    
                    self.removeCR(requestID: requestID)
                    
                    log.debug(message: "successfully handled receivedCRResult", event: "receivedCRResult", info: "result: \(CRResultPacket.result)")
                }
            } catch {
                log.error(message: "failed to handle receivedCRResult", event: "ChannelDC.receivedCRResult", error: error)
                ack.with(false)
            }
        }
    }
    
    func receivedCD(data: [Any],
                    ack: SocketAckEmitter) {
        Task {
            do {
                guard let data = data.first as? Data else { throw DCError.typecastError( err: "data failed to typecast to Data or is nil") }
                
                let CDPacket = try DataU.shared.jsonDecodeFromData(packet: CDPacket.self,
                                                                   data: data)
                
                let deletionDate = try DateU.shared.dateFromString(CDPacket.deletionDate)
                
                let SChannel = try await DataPC.shared.fetchSMO(entity: Channel.self,
                                                                predObject: ["channelID": CDPacket.channelID])
                
                let SRU = try await DataPC.shared.fetchSMO(entity: RemoteUser.self,
                                                           predObject: ["uID": SChannel.uID])
                
                let SCD = try await DataPC.shared.createCD(deletionID: CDPacket.deletionID,
                                                           channelType: "RU",
                                                           deletionDate: deletionDate,
                                                           type: CDPacket.type,
                                                           name: SRU.username,
                                                           icon: SRU.avatar,
                                                           nUsers: 1,
                                                           isOrigin: false)
                self.syncCD(CD: SCD)
                
                if CDPacket.type == "clear" {
                    let SChannel = try await DataPC.shared.updateMO(entity: Channel.self,
                                                                    predicateProperty: "channelID",
                                                                    predicateValue: CDPacket.channelID,
                                                                    property: ["lastMessageDate"],
                                                                    value: [nil])
                    self.syncChannel(channel: SChannel)

                    try await MessageDC.shared.clearChannelMessages(channelID: CDPacket.channelID)
                } else if CDPacket.type == "delete" {
                    try await DataPC.shared.fetchDeleteMO(entity: Channel.self,
                                                          predicateProperty: "channelID",
                                                          predicateValue: CDPacket.channelID)
                    self.removeChannel(channelID: CDPacket.channelID)

                    try await DataPC.shared.fetchDeleteMO(entity: RemoteUser.self,
                                                          predicateProperty: "uID",
                                                          predicateValue: SRU.uID)

                    try await MessageDC.shared.deleteChannelMessages(channelID: CDPacket.channelID)
                }
                
                ack.with(NSNull())
                
                do {
                    try await self.sendCDResult(deletionID: CDPacket.deletionID,
                                                uID: SRU.uID)
                    
                } catch {
                }
            } catch {
                ack.with(false)
            }
        }
    }
    
    func receivedCDResult(data: [Any],
                          ack: SocketAckEmitter) {
        Task {
            do {
                guard let data = data.first as? Data else { throw DCError.typecastError( err: "data failed to typecast to Data or is nil") }
                
                let CDResult = try DataU.shared.jsonDataToDictionary(data)
                
                guard let deletionID = CDResult["deletionID"] as? String,
                      let uID = CDResult["uID"] as? String,
                      let date = CDResult["date"] as? String else { throw DCError.jsonError() }
                
                let remoteDeletedDate = try DateU.shared.dateFromString(date)
                
                let SCD = try await DataPC.shared.fetchSMO(entity: ChannelDeletion.self,
                                                           predObject: ["deletionID": deletionID])
                
                if var toDeleteuIDs = SCD.toDeleteuIDs?.components(separatedBy: ",") {
                    toDeleteuIDs = toDeleteuIDs.filter { $0 != uID }
                    let uIDs = toDeleteuIDs.joined(separator: ",")
                    
                    if toDeleteuIDs.isEmpty {
                        let updatedSCD = try await DataPC.shared.updateMO(entity: ChannelDeletion.self,
                                                                          property: ["toDeleteuIDs", "remoteDeletedDate"],
                                                                          value: [uIDs, remoteDeletedDate],
                                                                          predObject: ["deletionID": deletionID])
                        self.removeCD(deletionID: deletionID)
                        self.syncCD(CD: updatedSCD)
                    } else {
                        let updatedSCD = try await DataPC.shared.updateMO(entity: ChannelDeletion.self,
                                                                          property: ["toDeleteuIDs"],
                                                                          value: [uIDs],
                                                                          predObject: ["deletionID": deletionID])
                        self.removeCD(deletionID: deletionID)
                        self.syncCD(CD: updatedSCD)
                    }
                    
                    ack.with(NSNull())
                    
                } else {
                    throw DCError.nilError()
                }
            } catch {
                ack.with(false)
            }
        }
    }
    
    func deleteUserTrace(data: [Any],
                         ack: SocketAckEmitter) {
        Task {
            do {
                guard let data = data.first as? Data else { throw DCError.typecastError( err: "data failed to typecast to Data or is nil") }
                
                let deletionData = try DataU.shared.jsonDataToDictionary(data)
                
                guard let uID = deletionData["uID"] as? String else { throw DCError.jsonError() }
                
                try await self.deleteUserTrace(uID: uID)
                
                ack.with(NSNull())
                
            } catch {
                ack.with(error.localizedDescription)
            }
        }
    }
}
