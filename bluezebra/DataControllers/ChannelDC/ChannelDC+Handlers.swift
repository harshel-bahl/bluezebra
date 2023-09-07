//
//  ChannelDC+Handlers.swift
//  bluezebra
//
//  Created by Harshel Bahl on 19/04/2023.
//

import Foundation

extension ChannelDC {
    
    /// Socket Handlers
    ///
    
    func addSocketHandlers() {
        self.userOnline()
        self.userDisconnected()
        self.receivedCR()
        self.receivedCRResult()
        self.receivedCD()
        self.receivedCDResult()
        self.deleteUserTrace()
    }
    
    func userOnline() {
        SocketController.shared.clientSocket.on("userOnline") { [weak self] (data, ack) in
            
            log.info(message: "userOnline triggered", event: "ChannelDC.userOnline")
            
            do {
                guard let self = self,
                      let uIDString = data.first as? String else { throw DCError.jsonError(err: "data was nil or failed to convert to a String") }
                
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
    }
    
    func userDisconnected() {
        SocketController.shared.clientSocket.on("userDisconnected") { [weak self] (data, ack) in
            
            log.info(message: "userDisconnected triggered", event: "ChannelDC.userDisconnected")
            
            do {
                guard let self = self else { throw  DCError.nilError(err: "self is nil") }
                
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
            } catch {
                log.error(message: "failed to handle userDiconnected", event: "ChannelDC.userDisconnected", error: error)
            }
        }
    }
    
    /// receivedCR
    /// - Handles the creation of a CR
    /// - Since the JSON packet needs to be decoded, if there is an error here or during failureEvent creation, then the sendCRFailure event cannot occur, so it isn't fired and the ack is allowed to timeOut to be dealt with on server
    func receivedCR() {
        SocketController.shared.clientSocket.on("receivedCR") { [weak self] (data, ack) in
#if DEBUG
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.receivedCR: triggered")
#endif
            
            guard let self = self else { return }
            
            Task {
                do {
                    guard let data = data.first as? Data else { throw DCError.typecastError( err: "data failed to typecast to Data or is nil") }
                    
                    let CRPacket = try DataU.shared.jsonDecodeFromData(packet: CRPacket.self,
                                                                       data: data)
                    
                    let date = try DateU.shared.dateFromString(CRPacket.date)
                    let originUserCreationDate = try DateU.shared.dateFromStringTZ(CRPacket.RU.creationDate)
                    
                    let originUserLastOnline: Date?
                    
                    if let lastOnline = CRPacket.RU.lastOnline {
                        originUserLastOnline = try DateU.shared.dateFromStringTZ(lastOnline)
                    } else {
                        originUserLastOnline = nil
                    }
                    
                    let SCR = try await DataPC.shared.createCR(requestID: CRPacket.requestID,
                                                               uID: CRPacket.RU.uID,
                                                               date: date,
                                                               isSender: false)
                    
                    let SRU = try await DataPC.shared.createRU(uID: CRPacket.RU.uID,
                                                               username: CRPacket.RU.username,
                                                               avatar: CRPacket.RU.avatar,
                                                               creationDate: originUserCreationDate,
                                                               lastOnline: originUserLastOnline)
                    self.syncCR(CR: SCR)

                    ack.with(NSNull())
                } catch {
                    ack.with(error.localizedDescription)
                }
            }
        }
    }
    
    
    func receivedCRResult() {
        SocketController.shared.clientSocket.on("receivedCRResult") { [weak self] (data, ack) in
            
            guard let self = self else { return }
            
            Task {
                do {
                    guard let data = data.first as? Data else { throw DCError.typecastError(err: "data failed to typecast to Data or is nil") }
                    
                    let CRResultPacket = try DataU.shared.jsonDecodeFromData(packet: CRResultPacket.self,
                                                                             data: data)
                    
                    let SCR = try await DataPC.shared.fetchSMO(entity: ChannelRequest.self,
                                                               predObject: ["requestID": CRResultPacket.requestID])
                    
                    if CRResultPacket.result == true {
                        let creationDate = try DateU.shared.dateFromString(CRResultPacket.creationDate)
                        
                        try await DataPC.shared.deleteMO(entity: ChannelRequest.self,
                                                         predObject: ["requestID": CRResultPacket.requestID])
                        self.removeCR(requestID: CRResultPacket.requestID)
                        
                        try await self.createChannel(channelID: CRResultPacket.channelID,
                                                                    uID: SCR.uID,
                                                                    creationDate: creationDate)
                        
                        ack.with(NSNull())
                    } else {
                        try await DataPC.shared.deleteMO(entity: RemoteUser.self,
                                                         predObject: ["uID": SCR.uID])
                        
                        try await DataPC.shared.deleteMO(entity: ChannelRequest.self,
                                                         predObject: ["requestID": CRResultPacket.requestID])
                        self.removeCR(requestID: CRResultPacket.requestID)
                        
                        ack.with(NSNull())
                    }
                } catch {
                    ack.with(error.localizedDescription)
                }
            }
        }
    }
    
    func receivedCD() {
        SocketController.shared.clientSocket.on("receivedCD") { [weak self] (data, ack) in
            
            guard let self = self else { return }
            
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
                    ack.with(error.localizedDescription)
                }
            }
        }
    }
    
    func receivedCDResult() {
        SocketController.shared.clientSocket.on("receivedCDResult") { [weak self] (data, ack) in
            
            guard let self = self else { return }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
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
                        ack.with(error.localizedDescription)
                    }
                }
            }
        }
    }

    func deleteUserTrace() {
        
        SocketController.shared.clientSocket.on("deleteUserTrace") { [weak self] (data, ack) in
            #if DEBUG
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.deleteUserTrace: triggered")
            #endif
            
            guard let self = self else { return }
            
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
}
