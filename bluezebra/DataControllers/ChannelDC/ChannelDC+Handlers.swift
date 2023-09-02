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
#if DEBUG
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.userOnline: triggered")
#endif
            
            guard let self = self,
                  let userID = data.first as? String else { return }
            
            if self.onlineUsers.keys.contains(userID) {
                DispatchQueue.main.async {
                    self.onlineUsers[userID] = true
                }
            }
        }
    }
    
    func userDisconnected() {
        SocketController.shared.clientSocket.on("userDisconnected") { [weak self] (data, ack) in
#if DEBUG
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.userDisconnected: triggered")
#endif
            
            guard let self = self else { return }
            
            Task {
                do {
                    guard let UID = data.first as? String else { throw DCError.jsonError() }
                    
                    if self.onlineUsers.keys.contains(UID) {
                        DispatchQueue.main.async {
                            self.onlineUsers[UID] = false
                        }
                    }
                    
                    let SRU = try await DataPC.shared.updateMO(entity: RemoteUser.self,
                    property: ["lastOnline"],
                                                               value: [DateU.shared.currDT],
                                                               predObject: ["userID": UID])
                } catch {
                }
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
                                                               UID: CRPacket.RU.UID,
                                                               date: date,
                                                               isSender: false)
                    
                    let SRU = try await DataPC.shared.createRU(UID: CRPacket.RU.UID,
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
                                                                    UID: SCR.UID,
                                                                    creationDate: creationDate)
                        
                        ack.with(NSNull())
                    } else {
                        try await DataPC.shared.deleteMO(entity: RemoteUser.self,
                                                         predObject: ["userID": SCR.UID])
                        
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
                                                               predObject: ["userID": SChannel.UID])
                    
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
                                                              predicateProperty: "userID",
                                                              predicateValue: SRU.userID)

                        try await MessageDC.shared.deleteChannelMessages(channelID: CDPacket.channelID)
                    }
                    
                    ack.with(NSNull())
                    
                    do {
                        try await self.sendCDResult(deletionID: CDPacket.deletionID,
                                                    userID: SRU.userID)
                        
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
                              let UID = CDResult["UID"] as? String,
                              let date = CDResult["date"] as? String else { throw DCError.jsonError() }
                        
                        let remoteDeletedDate = try DateU.shared.dateFromString(date)
                        
                        let SCD = try await DataPC.shared.fetchSMO(entity: ChannelDeletion.self,
                                                                   predObject: ["deletionID": deletionID])
                        
                        if var toDeleteUIDs = SCD.toDeleteUIDs?.components(separatedBy: ",") {
                            toDeleteUIDs = toDeleteUIDs.filter { $0 != UID }
                            let UIDs = toDeleteUIDs.joined(separator: ",")
                            
                            if toDeleteUIDs.isEmpty {
                                let updatedSCD = try await DataPC.shared.updateMO(entity: ChannelDeletion.self,
                                                                                  property: ["toDeleteUIDs", "remoteDeletedDate"],
                                                                                  value: [UIDs, remoteDeletedDate],
                                                                                  predObject: ["deletionID": deletionID])
                                self.removeCD(deletionID: deletionID)
                                self.syncCD(CD: updatedSCD)
                            } else {
                                let updatedSCD = try await DataPC.shared.updateMO(entity: ChannelDeletion.self,
                                                                                  property: ["toDeleteUIDs"],
                                                                                  value: [UIDs],
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
                    
                    guard let UID = deletionData["UID"] as? String else { throw DCError.jsonError() }
                    
                    try await self.deleteUserTrace(UID: UID)
                    
                    ack.with(NSNull())
                    
                } catch {
                    ack.with(error.localizedDescription)
                }
            }
        }
    }
}
