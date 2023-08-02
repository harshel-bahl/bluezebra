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
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.userOnline: triggered")
            
            guard let self = self,
                  let userID = data.first as? String else { return }
            
            if self.onlineUsers.keys.contains(userID) {
                self.onlineUsers[userID] = true
            }
        }
    }
    
    func userDisconnected() {
        SocketController.shared.clientSocket.on("userDisconnected") { [weak self] (data, ack) in
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.userDisconnected: triggered")
            
            guard let self = self,
                  let data = data.first as? NSDictionary,
                  let userID = data.allKeys[0] as? String,
                  let lastOnline = data[userID] as? String else { return }
            
            if self.onlineUsers.keys.contains(userID) {
                self.onlineUsers[userID] = false
            }
            
            guard let lastOnline = DateU.shared.dateFromString(lastOnline) else { return }
            
            Task {
                guard let SRU = try? await DataPC.shared.updateMO(entity: RemoteUser.self,
                                                                property: ["lastOnline"],
                                                                value: [lastOnline]) else { return }
                self.syncRU(RU: SRU)
            }
        }
    }
    
    func receivedCR() {
        SocketController.shared.clientSocket.on("receivedCR") { [weak self] (data, ack) in
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.receivedCR: triggered")
            do {
                guard let self = self,
                      let data = data.first else { throw DCError.nilError }
                
                guard let packet = try? DataU.shared.jsonDecodeFromData(packet: CRPacket.self,
                                                                        data: data) else { throw DCError.jsonError }
                
                let channelPacket = packet.channel
                let RUPacket = packet.remoteUser
                
                guard let date = DateU.shared.dateFromString(packet.date),
                      let creationDate = DateU.shared.dateFromString(RUPacket.creationDate) else { throw DCError.typecastError }
                
                Task {
                    do {
                        let SCR = try await DataPC.shared.createCR(channelID: channelPacket.channelID,
                                                                   userID: RUPacket.userID,
                                                                   date: date,
                                                                   isSender: false)
                        
                        let SRU = try? await DataPC.shared.createRU(userID: RUPacket.userID,
                                                                    username: RUPacket.username,
                                                                    avatar: RUPacket.avatar,
                                                                    creationDate: creationDate)
                        
                        let _ = try await DataPC.shared.createChannel(channelID: channelPacket.channelID,
                                                                             userID: RUPacket.userID,
                                                                             creationDate: date)
                        
                        self.syncCR(CR: SCR)
                        if let SRU = SRU { self.syncRU(RU: SRU) }
                        ack.with(NSNull())
                    } catch {
                        try? await DataPC.shared.fetchDeleteMOsAsync(entity: ChannelRequest.self,
                                                                     predicateProperty: "channelID",
                                                                     predicateValue: channelPacket.channelID)
                        try? await DataPC.shared.fetchDeleteMOsAsync(entity: Channel.self,
                                                                     predicateProperty: "channelID",
                                                                     predicateValue: channelPacket.channelID)
                        try? await DataPC.shared.fetchDeleteMOsAsync(entity: RemoteUser.self,
                                                                     predicateProperty: "userID",
                                                                     predicateValue: RUPacket.userID)
                        ack.with(false)
                    }
                }
            } catch {
                print("SERVER \(DateU.shared.logTS) -- ChannelDC.receivedCR: FAILED \(error)")
                ack.with(false)
            }
        }
    }
    
    func receivedCRResult() {
        SocketController.shared.clientSocket.on("receivedCRResult") { [weak self] (data, ack) in
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.receivedCRResult: triggered")
            
            guard let self = self,
                  let data = data.first as? NSDictionary,
                  let channelID = data["channelID"] as? String,
                  let date = data["date"] as? String,
                  let requestResult = data["result"] as? Bool else { return }
            
            Task {
                do {
                    let channelRequest = try await DataPC.shared.fetchSMOAsync(entity: ChannelRequest.self,
                                                                               predicateProperty: "channelID",
                                                                               predicateValue: channelID)
                    if requestResult {
                        let channel = try await DataPC.shared.updateMO(entity: Channel.self,
                                                                       predicateProperty: "channelID",
                                                                       predicateValue: channelID,
                                                                       property: ["active"],
                                                                       value: [true])
                        try await self.syncChannels()
                        
                        try await DataPC.shared.fetchDeleteMOAsync(entity: ChannelRequest.self,
                                                                   predicateProperty: "channelID",
                                                                   predicateValue: channelID)
                        try await self.syncCRs()
                        
                        ack.with(true)
                    } else if !requestResult {
                        try await DataPC.shared.fetchDeleteMOAsync(entity: Channel.self,
                                                                   predicateProperty: "channelID",
                                                                   predicateValue: channelID)
                        try await self.syncChannels()
                        
                        try await DataPC.shared.fetchDeleteMOAsync(entity: RemoteUser.self,
                                                                   predicateProperty: "userID",
                                                                   predicateValue: channelRequest.userID)
                        try await self.syncRUs()
                        
                        try await DataPC.shared.fetchDeleteMOAsync(entity: ChannelRequest.self,
                                                                   predicateProperty: "channelID",
                                                                   predicateValue: channelID)
                        try await self.syncCRs()
                        
                        ack.with(true)
                    }
                } catch {
                    print("CLIENT \(DateU.shared.logTS) -- ChannelDC.receivedCRResult: FAILED")
                    ack.with(false)
                }
            }
        }
    }
    
    func receivedCD() {
        SocketController.shared.clientSocket.on("receivedCD") { [weak self] (data, ack) in
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.receivedCD: triggered")
            
            guard let self = self,
                  let data = data.first,
                  let CDPacket = try? DataU.shared.jsonDecodeFromData(packet: CDPacket.self,
                                                              data: data),
                  let deletionDate = DateU.shared.dateFromString(CDPacket.deletionDate) else { return }
            
            Task {
                do {
                    let SChannel = try await DataPC.shared.fetchSMOAsync(entity: Channel.self,
                                                                         predicateProperty: "channelID",
                                                                         predicateValue: CDPacket.channelID)
                    
                    let remoteUser = try await DataPC.shared.fetchSMOAsync(entity: RemoteUser.self,
                                                                           predicateProperty: "userID",
                                                                           predicateValue: SChannel.userID)
                    
                    let channelDeletion = try await DataPC.shared.createCD(deletionID: CDPacket.deletionID,
                                                                                        channelType: "user",
                                                                                        deletionDate: deletionDate,
                                                                                        type: CDPacket.type,
                                                                                        name: remoteUser.username,
                                                                                        icon: remoteUser.avatar,
                                                                                        nUsers: 1,
                                                                                        toDeleteUserIDs: [],
                                                                                        isOrigin: true)
                    try await self.syncCDs()
                    
                    if CDPacket.type=="clear" {
                        // delete all messages from channel
                        
                        let _ = try await DataPC.shared.updateMO(entity: Channel.self,
                                                                 predicateProperty: "channelID",
                                                                 predicateValue: SChannel.channelID,
                                                                 property: ["lastMessageDate"],
                                                                 value: [nil])
                        try await self.syncChannels()
                        
                    } else if CDPacket.type=="delete" {
                        // delete all messages from channel
                        
                        try await DataPC.shared.fetchDeleteMOsAsync(entity: Channel.self,
                                                                    predicateProperty: "channelID",
                                                                    predicateValue: CDPacket.channelID)
                        try await self.syncChannels()
                        
                        try await DataPC.shared.fetchDeleteMOAsync(entity: RemoteUser.self,
                                                                   predicateProperty: "userID",
                                                                   predicateValue: SChannel.userID)
                        try await self.syncRUs()
                    }
                } catch {
                    print("CLIENT \(DateU.shared.logTS) -- ChannelDC.receivedCD: FAILED")
                }
            }
        }
    }
    
    func receivedCDResult() {
        SocketController.shared.clientSocket.on("receivedCDResult") { [weak self] (data, ack) in
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.receivedCDResult: triggered")
            
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
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.deleteUserTrace: triggered")

            guard let self = self,
                  let data = data.first as? NSDictionary,
                  let userID = data["userID"] as? String else { return }
            
            Task {
                /// Delete remoteUser
                try await DataPC.shared.fetchDeleteMOsAsync(entity: RemoteUser.self,
                                                            predicateProperty: "userID",
                                                            predicateValue: userID)
                try await self.syncRUs()
                
                /// Delete channelRequests
                try await DataPC.shared.fetchDeleteMOsAsync(entity: ChannelRequest.self,
                                                            predicateProperty: "userID",
                                                            predicateValue: userID)
                try await self.syncCRs()
                
                /// Delete channel
                try await DataPC.shared.fetchDeleteMOsAsync(entity: Channel.self,
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
