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
                guard let _ = try? await DataPC.shared.updateMO(entity: RemoteUser.self,
                                                                property: ["lastOnline"],
                                                                value: [lastOnline]) else { return }
                await self.fetchRemoteUsers()
            }
        }
    }
    
    func receivedCR() {
        SocketController.shared.clientSocket.on("receivedCR") { [weak self] (data, ack) in
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.receivedCR: triggered")
            
            guard let self = self,
                  let data = data.first,
                  let packet = try? self.jsonDecodeFromData(packet: CRPacket.self,
                                                            data: data) else { return }
            Task {
                do {
                    let channelPacket = packet.channel
                    let RUPacket = packet.remoteUser
                    
                    guard let date = DateU.shared.dateFromString(packet.date),
                          let creationDate = DateU.shared.dateFromString(RUPacket.creationDate) else { return }
                    
                    let _ = try await DataPC.shared.createChannelRequest(channelID: channelPacket.channelID,
                                                                         userID: RUPacket.userID,
                                                                         date: date,
                                                                         isSender: false)
                    await self.fetchCRs()
                    
                    let sRU = try? await DataPC.shared.createRemoteUser(userID: RUPacket.userID,
                                                                        username: RUPacket.username,
                                                                        avatar: RUPacket.avatar,
                                                                        creationDate: creationDate)
                    if sRU != nil { await self.fetchRemoteUsers() }
                    
                    let sChannel = try await DataPC.shared.createChannel(channelID: channelPacket.channelID,
                                                                         userID: RUPacket.userID,
                                                                         creationDate: date)
                    await self.fetchUserChannels()
                    
                    ack.with(true)
                } catch {
                    ack.with(false)
                }
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
                        await self.fetchUserChannels()
                        
                        try await DataPC.shared.fetchDeleteMOAsync(entity: ChannelRequest.self,
                                                                   predicateProperty: "channelID",
                                                                   predicateValue: channelID)
                        ack.with(true)
                    } else if !requestResult {
                        try await DataPC.shared.fetchDeleteMOAsync(entity: Channel.self,
                                                                   predicateProperty: "channelID",
                                                                   predicateValue: channelID)
                        
                        try await DataPC.shared.fetchDeleteMOAsync(entity: RemoteUser.self,
                                                                   predicateProperty: "userID",
                                                                   predicateValue: channelRequest.userID)
                        
                        try await DataPC.shared.fetchDeleteMOAsync(entity: ChannelRequest.self,
                                                                   predicateProperty: "channelID",
                                                                   predicateValue: channelID)
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
        SocketController.shared.clientSocket.on("receivedChannelDeletion") { [weak self] (data, ack) in
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.receivedChannelDeletion: triggered")
            
            guard let self = self,
                  let data = data.first,
                  let CDPacket = try? self.jsonDecodeFromData(packet: CDPacket.self,
                                                              data: data),
                  let deletionDate = DateU.shared.dateFromString(CDPacket.deletionDate) else { return }
            
            Task {
//                do {
//                    let channel = try await DataPC.shared.fetchSMOAsync(entity: Channel.self,
//                                                                        predicateProperty: "channelID",
//                                                                        predicateValue: CDPacket.channelID)
//
//                    guard let remoteUserID = channel.userID else { throw DCError.failed }
//
//                    let remoteUser = try await DataPC.shared.fetchSMOAsync(entity: RemoteUser.self,
//                                                                           predicateProperty: "userID",
//                                                                           predicateValue: remoteUserID)
//
//                    let channelDeletion = try await DataPC.shared.createChannelDeletion(channelType: channel.channelType,
//                                                                                        deletionDate: deletionDate,
//                                                                                        type: CDPacket.type,
//                                                                                        name: remoteUser.username,
//                                                                                        icon: remoteUser.avatar,
//                                                                                        nUsers: 1,
//                                                                                        toDeleteUserIDs: [remoteUserID],
//                                                                                        isOrigin: true)
//                    await self.fetchChannelDeletions()
//
//                    if channelDeletion.type=="clear" {
//                        // delete all messages from channel
//                    } else if channelDeletion.type=="delete" {
//                        // delete all messages from channel
//
//                        try await DataPC.shared.fetchDeleteMOsAsync(entity: Channel.self,
//                                                                    predicateProperty: "channelID",
//                                                                    predicateValue: CDPacket.channelID)
//                        await self.fetchUserChannels()
//                    }
//
//                    let RUCheck = try await self.checkRUInTeams(userID: remoteUserID)
//
//                    if !RUCheck {
//                        try await DataPC.shared.fetchDeleteMOAsync(entity: RemoteUser.self,
//                                                                   predicateProperty: "userID",
//                                                                   predicateValue: remoteUserID)
//                        await self.fetchRemoteUsers()
//                    }
//                } catch {
//                    print("CLIENT \(DateU.shared.logTS) -- ChannelDC.receivedChannelDeletion: FAILED")
//                }
            }
        }
    }
    
    func receivedCDResult() {
        SocketController.shared.clientSocket.on("receivedChannelDeletionResult") { [weak self] (data, ack) in
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.receivedChannelDeletionResult: triggered")
            
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
    
    func receivedTeamInvite() {
        //                        guard let teamPacket = packet.teamPacket,
        //                              let date = DateU.shared.dateFromString(packet.date),
        //                              let requestingUserID = packet.requestingUserID else { return }
        //                        let channel = packet.channel
        //
        //                        let _ = try await DataPC.shared.createChannelRequest(channelID: channel.channelID,
        //                                                                             teamID: teamPacket.teamID,
        //                                                                             date: date,
        //                                                                             isSender: false,
        //                                                                             requestingUserID: requestingUserID)
        //                        await self.fetchChannelRequests()
        //
        //                        let _ = try await DataPC.shared.createTeam(teamID: teamPacket.teamID,
        //                                                                   userIDs: teamPacket.userIDs.components(separatedBy: ","),
        //                                                                   nUsers: teamPacket.nUsers,
        //                                                                   leads: teamPacket.leads,
        //                                                                   name: teamPacket.name,
        //                                                                   icon: teamPacket.icon,
        //                                                                   creationUserID: teamPacket.creationUserID,
        //                                                                   creationDate: teamPacket.creationDate)
        //                        await self.fetchTeamChannels()
        //
        //                        let _ = try await DataPC.shared.createChannel(channelID: channel.channelID,
        //                                                                      channelType: channel.channelType,
        //                                                                      teamID: teamPacket.teamID,
        //                                                                      creationUserID: channel.creationUserID)
        //                        await self.fetchTeamChannels()
        //
        //                        ack.with(true)
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
                await self.fetchRemoteUsers()
                
                /// Delete channelRequests
                try await DataPC.shared.fetchDeleteMOsAsync(entity: ChannelRequest.self,
                                                            predicateProperty: "userID",
                                                            predicateValue: userID)
                await self.fetchCRs()
                
                /// Delete channel
                try await DataPC.shared.fetchDeleteMOsAsync(entity: Channel.self,
                                                            predicateProperty: "userID",
                                                            predicateValue: userID)
                await self.fetchUserChannels()
                
                // update team userIDs to remove user's userID
                // can be done by calling update with custom predicate of contains userID, then change to list and remove userID
                
                /// Delete messages
                
            }
        }
    }
}
