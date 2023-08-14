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
                self.onlineUsers[userID] = true
            }
        }
    }
    
    func userDisconnected() {
        SocketController.shared.clientSocket.on("userDisconnected") { [weak self] (data, ack) in
#if DEBUG
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.userDisconnected: triggered")
#endif
            
            guard let self = self,
                  let data = data.first as? NSDictionary,
                  let userID = data.allKeys[0] as? String,
                  let lastOnline = data[userID] as? String else { return }
            
            if self.onlineUsers.keys.contains(userID) {
                self.onlineUsers[userID] = false
            }
            
            Task {
                do {
                    let lastOnline = try DateU.shared.dateFromString(lastOnline)
                    
                    let SRU = try await DataPC.shared.updateMO(entity: RemoteUser.self,
                                                               property: ["lastOnline"],
                                                               value: [lastOnline])
                    self.syncRU(RU: SRU)
                } catch {
#if DEBUG
                    DataU.shared.handleFailure(function: "ChannelDC.userDisconnected", err: error)
#endif
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
                    guard let data = data.first as? Data else { throw DCError.typecastError(func: "ChannelDC.receivedCR", err: "data failed to typecast to Data or is nil")}
                    
                    let CRPacket = try DataU.shared.jsonDecodeFromData(packet: CRPacket.self,
                                                                       data: data)
                    
                    let date = try DateU.shared.dateFromString(CRPacket.date)
                    let originUserCreationDate = try DateU.shared.dateFromStringTZ(CRPacket.originUser.creationDate)
                    
                    let originUserLastOnline: Date?
                    
                    if let lastOnline = CRPacket.originUser.lastOnline {
                        originUserLastOnline = try DateU.shared.dateFromStringTZ(lastOnline)
                    } else {
                        originUserLastOnline = nil
                    }
                    
                    let SCR = try await DataPC.shared.createCR(requestID: CRPacket.requestID,
                                                               userID: CRPacket.originUser.userID,
                                                               date: date,
                                                               isSender: false)
                    
                    let SRU = try await DataPC.shared.createRU(userID: CRPacket.originUser.userID,
                                                               username: CRPacket.originUser.username,
                                                               avatar: CRPacket.originUser.avatar,
                                                               creationDate: originUserCreationDate,
                                                               lastOnline: originUserLastOnline)
                    self.syncCR(CR: SCR)
                    self.syncRU(RU: SRU)

                    ack.with(NSNull())
                } catch {
                    DataU.shared.handleFailure(function: "receivedCR", err: error)
                    ack.with(error.localizedDescription)
                }
            }
        }
    }
    
    
    func receivedCRResult() {
        SocketController.shared.clientSocket.on("receivedCRResult") { [weak self] (data, ack) in
#if DEBUG
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.receivedCRResult: triggered")
#endif
            guard let self = self else { return }
            
            Task {
                do {
                    guard let data = data.first as? Data else { throw DCError.typecastError(func: "ChannelDC.receivedCRResult", err: "data failed to typecast to Data or is nil")}
                    
                    let CRResultPacket = try DataU.shared.jsonDecodeFromData(packet: CRResultPacket.self,
                                                                             data: data)
                    
                    let SCR = try await DataPC.shared.fetchSMO(entity: ChannelRequest.self,
                                                               predicateProperty: "requestID",
                                                               predicateValue: CRResultPacket.requestID)
                    
                    if CRResultPacket.result == true {
                        let creationDate = try DateU.shared.dateFromString(CRResultPacket.creationDate)
                        
                        try await DataPC.shared.fetchDeleteMO(entity: ChannelRequest.self,
                                                              predicateProperty: "requestID",
                                                              predicateValue: CRResultPacket.requestID)
                        self.removeCR(requestID: CRResultPacket.requestID)
                        
                        let SChannel = try await DataPC.shared.createChannel(channelID: CRResultPacket.channelID,
                                                                             userID: SCR.userID,
                                                                             creationDate: creationDate)
                        self.syncChannel(channel: SChannel)
                        
                        ack.with(NSNull())
                    } else {
                        try await DataPC.shared.fetchDeleteMO(entity: RemoteUser.self,
                                                              predicateProperty: "userID",
                                                              predicateValue: SCR.userID)
                        self.removeRU(userID: SCR.userID)
                        
                        try await DataPC.shared.fetchDeleteMO(entity: ChannelRequest.self,
                                                              predicateProperty: "requestID",
                                                              predicateValue: CRResultPacket.requestID)
                        self.removeCR(requestID: CRResultPacket.requestID)
                        
                        ack.with(NSNull())
                    }
                } catch {
                    DataU.shared.handleFailure(function: "receivedCRResult", err: error)
                    ack.with(error.localizedDescription)
                }
            }
        }
    }
    
    func receivedCD() {
        SocketController.shared.clientSocket.on("receivedCD") { [weak self] (data, ack) in
#if DEBUG
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.receivedCD: triggered")
#endif
            
            guard let self = self else { return }
            
            Task {
                do {
                    guard let data = data.first as? Data else { throw DCError.typecastError(func: "ChannelDC.receivedCD", err: "data failed to typecast to Data or is nil")}
                    
                    let CDPacket = try DataU.shared.jsonDecodeFromData(packet: CDPacket.self,
                                                                       data: data)
                    
                    let deletionDate = try DateU.shared.dateFromString(CDPacket.deletionDate)
                    
                    let SChannel = try await DataPC.shared.fetchSMO(entity: Channel.self,
                                                                    predicateProperty: "channelID",
                                                                    predicateValue: CDPacket.channelID)
                    
                    let SRU = try await DataPC.shared.fetchSMO(entity: RemoteUser.self,
                                                               predicateProperty: "userID",
                                                               predicateValue: SChannel.userID)
                    
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
                        self.removeRU(userID: SRU.userID)

                        try await MessageDC.shared.deleteChannelMessages(channelID: CDPacket.channelID)
                    }
                    
                    ack.with(NSNull())
                } catch {
                    DataU.shared.handleFailure(function: "receivedCD", err: error)
                    ack.with(error.localizedDescription)
                }
            }
        }
    }
    
    func receivedCDResult() {
        SocketController.shared.clientSocket.on("receivedCDResult") { [weak self] (data, ack) in
            #if DEBUG
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.receivedCDResult: triggered")
            #endif
            
//            guard let self = self,
//                  let data = data.first as? NSDictionary,
//                  let deletionID = data["deletionID"] as? String,
//                  let dateString = data["remoteDeletedDate"] as? String,
//                  let remoteDeletedDate = DateU.shared.dateFromString(dateString) else { return }
//
//            Task {
//                let _ = try await DataPC.shared.updateMO(entity: ChannelDeletion.self,
//                                                         predicateProperty: "deletionID",
//                                                         predicateValue: deletionID,
//                                                         property: ["toDeleteUserIDs", "remoteDeletedDate"],
//                                                         value: [[String]().joined(separator: ","), remoteDeletedDate])
//                await self.fetchChannelDeletions()
//            }
        }
    }

    func deleteUserTrace() {
        
        SocketController.shared.clientSocket.on("deleteUserTrace") { [weak self] (data, ack) in
            #if DEBUG
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.deleteUserTrace: triggered")
            #endif
            
            guard let self = self,
                  let data = data.first as? NSDictionary,
                  let userID = data["userID"] as? String else { return }
            
            Task {
                /// Delete remoteUser
                try await DataPC.shared.fetchDeleteMOs(entity: RemoteUser.self,
                                                            predicateProperty: "userID",
                                                            predicateValue: userID)
                try await self.syncRUs()
                
                /// Delete channelRequests
                try await DataPC.shared.fetchDeleteMOs(entity: ChannelRequest.self,
                                                            predicateProperty: "userID",
                                                            predicateValue: userID)
                try await self.syncCRs()
                
                /// Delete channel
                try await DataPC.shared.fetchDeleteMOs(entity: Channel.self,
                                                            predicateProperty: "userID",
                                                            predicateValue: userID)
                try await self.syncChannels()
                
                // update team userIDs to remove user's userID
                // can be done by calling update with custom predicate of contains userID, then change to list and remove userID
                
                /// Delete messages
                
            }
        }
    }
}
