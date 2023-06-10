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
        self.receivedChannelRequest()
        self.receivedChannelRequestResult()
        self.receivedChannelDeletion()
        self.receivedChannelDeletionResult()
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
    
    func receivedChannelRequest() {
        SocketController.shared.clientSocket.on("receivedChannelRequest") { [weak self] (data, ack) in
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.receivedChannelRequest: triggered")
            
            guard let self = self,
                  let data = data.first,
                  let packet = try? self.jsonDecodeFromData(packet: ChannelRequestPacket.self,
                                                                data: data)  else { return }
            Task {
                do {
                    if packet.channel.channelType == "user" {
                        guard let RUPacket = packet.remoteUser,
                              let date = DateU.shared.dateFromString(packet.date) else { return }
                        let channel = packet.channel
                        
                        let _ = try await DataPC.shared.createChannelRequest(channelID: channel.channelID,
                                                                             userID: RUPacket.userID,
                                                                             date: date,
                                                                             isSender: false)
                        await self.fetchChannelRequests()
                        
                        let remoteUser = try? await DataPC.shared.createRemoteUser(userID: RUPacket.userID,
                                                                                   username: RUPacket.username,
                                                                                   avatar: RUPacket.avatar)
                        if remoteUser != nil { await self.fetchRemoteUsers() }
                        
                        let _ = try await DataPC.shared.createChannel(channelID: channel.channelID,
                                                                      channelType: channel.channelType,
                                                                      userID: RUPacket.userID,
                                                                      creationUserID: channel.creationUserID)
                        await self.fetchUserChannels()
                        
                        ack.with(true)
                        
                    } else if packet.channel.channelType == "team" {
                        guard let teamPacket = packet.teamPacket,
                              let date = DateU.shared.dateFromString(packet.date),
                              let requestingUserID = packet.requestingUserID else { return }
                        let channel = packet.channel
                        
                        let _ = try await DataPC.shared.createChannelRequest(channelID: channel.channelID,
                                                                             teamID: teamPacket.teamID,
                                                                             date: date,
                                                                             isSender: false,
                                                                             requestingUserID: requestingUserID)
                        await self.fetchChannelRequests()
                        
                        let _ = try await DataPC.shared.createTeam(teamID: teamPacket.teamID,
                                                                   userIDs: teamPacket.userIDs.components(separatedBy: ","),
                                                                   nUsers: teamPacket.nUsers,
                                                                   leads: teamPacket.leads,
                                                                   name: teamPacket.name,
                                                                   icon: teamPacket.icon,
                                                                   creationUserID: teamPacket.creationUserID,
                                                                   creationDate: teamPacket.creationDate)
                        await self.fetchTeamChannels()
                        
                        let _ = try await DataPC.shared.createChannel(channelID: channel.channelID,
                                                                      channelType: channel.channelType,
                                                                      teamID: teamPacket.teamID,
                                                                      creationUserID: channel.creationUserID)
                        await self.fetchTeamChannels()
                        
                        ack.with(true)
                    }
                } catch {
                    ack.with(false)
                }
            }
        }
    }
    
    func receivedChannelRequestResult() {
        SocketController.shared.clientSocket.on("receivedChannelRequestResult") { [weak self] (data, ack) in
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.receivedChannelRequestResult: triggered")
            
            guard let self = self,
                  let data = data.first as? NSDictionary,
                  let channelID = data["channelID"] as? String,
                  let requestResult = data["result"] as? Bool else { return }
            
            Task {
                do {
                    let channel = try await DataPC.shared.updateMO(entity: Channel.self,
                                                                   predicateProperty: "channelID",
                                                                   predicateValue: channelID,
                                                                   property: ["active"],
                                                                   value: [true])
                    if requestResult {
                        if channel.channelType == "user" {
                            await self.fetchUserChannels()
                        } else if channel.channelType == "team" {
                            await self.fetchTeamChannels()
                        }
                        
                        if channel.channelType == "user" {
                            let _ = try await DataPC.shared.updateMO(entity: RemoteUser.self,
                                                                     predicateProperty: "userID",
                                                                     predicateValue: channel.userID,
                                                                     property: ["active"],
                                                                     value: [true])
                            await self.fetchRemoteUsers()
                        } else if channel.channelType == "team" {
                            let _ = try await DataPC.shared.updateMO(entity: Team.self,
                                                                     predicateProperty: "teamID",
                                                                     predicateValue: channel.teamID,
                                                                     property: ["active"],
                                                                     value: [true])
                            await self.fetchTeams()
                        }
                        
                        try await DataPC.shared.fetchDeleteMOAsync(entity: ChannelRequest.self,
                                                                   predicateProperty: "channelID",
                                                                   predicateValue: channelID)
                    } else if !requestResult {
                        try await DataPC.shared.fetchDeleteMOAsync(entity: Channel.self,
                                                                   predicateProperty: "channelID",
                                                                   predicateValue: channelID)
                        
                        if channel.channelType == "user" {
                            try await DataPC.shared.fetchDeleteMOAsync(entity: RemoteUser.self,
                                                                       predicateProperty: "userID",
                                                                       predicateValue: channel.userID)
                        } else if channel.channelType == "team" {
                            try await DataPC.shared.fetchDeleteMOAsync(entity: Team.self,
                                                                       predicateProperty: "teamID",
                                                                       predicateValue: channel.teamID)
                        }
                        
                        try await DataPC.shared.fetchDeleteMOAsync(entity: ChannelRequest.self,
                                                                   predicateProperty: "channelID",
                                                                   predicateValue: channelID)
                    }
                } catch {
                    print("CLIENT \(DateU.shared.logTS) -- ChannelDC.receivedChannelRequestResult: FAILED")
                }
            }
        }
    }
    
    func receivedChannelDeletion() {
        SocketController.shared.clientSocket.on("receivedChannelDeletion") { [weak self] (data, ack) in
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.receivedChannelDeletion: triggered")
            
            guard let self = self,
                  let data = data.first,
                  let CDPacket = try? self.jsonDecodeFromData(packet: ChannelDeletionPacket.self,
                                                              data: data),
                  let deletionDate = DateU.shared.dateFromString(CDPacket.deletionDate) else { return }
            
            Task {
                do {
                    let channel = try await DataPC.shared.fetchSMOAsync(entity: Channel.self,
                                                                        predicateProperty: "channelID",
                                                                        predicateValue: CDPacket.channelID)
                    
                    guard let remoteUserID = channel.userID else { throw DCError.failed }
                    
                    let remoteUser = try await DataPC.shared.fetchSMOAsync(entity: RemoteUser.self,
                                                                           predicateProperty: "userID",
                                                                           predicateValue: remoteUserID)
                    
                    let channelDeletion = try await DataPC.shared.createChannelDeletion(channelType: channel.channelType,
                                                                                        deletionDate: deletionDate,
                                                                                        type: CDPacket.type,
                                                                                        name: remoteUser.username,
                                                                                        icon: remoteUser.avatar,
                                                                                        nUsers: 1,
                                                                                        toDeleteUserIDs: [remoteUserID],
                                                                                        isOrigin: true)
                    await self.fetchChannelDeletions()
                    
                    if channelDeletion.type=="clear" {
                        // delete all messages from channel
                    } else if channelDeletion.type=="delete" {
                        // delete all messages from channel
                        
                        try await DataPC.shared.fetchDeleteMOsAsync(entity: Channel.self,
                                                                    predicateProperty: "channelID",
                                                                    predicateValue: CDPacket.channelID)
                        await self.fetchUserChannels()
                    }
                    
                    let RUCheck = try await self.checkRUInTeams(userID: remoteUserID)
                    
                    if !RUCheck {
                        try await DataPC.shared.fetchDeleteMOAsync(entity: RemoteUser.self,
                                                                   predicateProperty: "userID",
                                                                   predicateValue: remoteUserID)
                        await self.fetchRemoteUsers()
                    }
                } catch {
                    print("CLIENT \(DateU.shared.logTS) -- ChannelDC.receivedChannelDeletion: FAILED")
                }
            }
        }
    }
    
    func receivedChannelDeletionResult() {
        SocketController.shared.clientSocket.on("receivedChannelDeletionResult") { [weak self] (data, ack) in
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.receivedChannelDeletionResult: triggered")
            
            guard let self = self,
                  let data = data.first as? NSDictionary,
                  let deletionID = data["deletionID"] as? String,
                  let dateString = data["remoteDeletedDate"] as? String,
                  let remoteDeletedDate = DateU.shared.dateFromString(dateString) else { return }
            
            Task {
                let _ = try await DataPC.shared.updateMO(entity: ChannelDeletion.self,
                                                         predicateProperty: "deletionID",
                                                         predicateValue: deletionID,
                                                         property: ["toDeleteUserIDs", "remoteDeletedDate"],
                                                         value: [[String]().joined(separator: ","), remoteDeletedDate])
                await self.fetchChannelDeletions()
            }
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
                await self.fetchRemoteUsers()
                
                /// Delete channelRequests
                try await DataPC.shared.fetchDeleteMOsAsync(entity: ChannelRequest.self,
                                                            predicateProperty: "userID",
                                                            predicateValue: userID)
                await self.fetchChannelRequests()
                
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
