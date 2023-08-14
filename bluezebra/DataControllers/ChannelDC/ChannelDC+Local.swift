//
//  ChannelDC+Local.swift
//  bluezebra
//
//  Created by Harshel Bahl on 19/04/2023.
//

import Foundation

extension ChannelDC {
    
    /// Local Sync Functions
    ///
    func syncAllData() async throws {
        if self.RUs.isEmpty { try await self.syncRUs() }
        if self.personalChannel == nil { try await self.syncPersonalChannel() }
        if self.channels.isEmpty { try await self.syncChannels() }
        if self.CRs.isEmpty { try await self.syncCRs() }
        if self.CDs.isEmpty { try await self.syncCDs() }
    }
    
    func syncRUs(fetchLimit: Int? = nil) async throws {
        
        let SMOs = try await DataPC.shared.fetchSMOs(entity: RemoteUser.self,
                                                     fetchLimit: fetchLimit,
                                                     showLogs: true)
        
        DispatchQueue.main.async {
            for SMO in SMOs {
                self.RUs[SMO.userID] = SMO
            }
        }
    }
    
    func syncPersonalChannel() async throws {
        let SMO = try await DataPC.shared.fetchSMO(entity: Channel.self,
                                                   predicateProperty: "channelID",
                                                   predicateValue: "personal",
                                                   showLogs: true)
        DispatchQueue.main.async {
            self.personalChannel = SMO
        }
    }
    
    func syncChannels(fetchLimit: Int? = nil) async throws {

        let predicate = NSPredicate(format: "channelID != %@", argumentArray: ["personal"])
        
        let SMOs = try await DataPC.shared.fetchSMOs(entity: Channel.self,
                                                     customPredicate: predicate,
                                                     fetchLimit: fetchLimit,
                                                     sortKey: "lastMessageDate",
                                                     showLogs: true)
        
        let sortedSMOs = self.sortNilDates(channels: SMOs)
        
        DispatchQueue.main.async {
            self.channels = sortedSMOs
        }
    }
    
    func syncCRs(fetchLimit: Int? = nil) async throws {
        
        let SMOs = try await DataPC.shared.fetchSMOs(entity: ChannelRequest.self,
                                                     fetchLimit: fetchLimit,
                                                     sortKey: "date",
                                                     showLogs: true)
        
        DispatchQueue.main.async {
            self.CRs = SMOs
        }
    }
    
    
    func syncCDs(fetchLimit: Int? = nil) async throws {
        
        let SMOs = try await DataPC.shared.fetchSMOs(entity: ChannelDeletion.self,
                                                     fetchLimit: fetchLimit,
                                                     sortKey: "deletionDate",
                                                     showLogs: true)
        
        DispatchQueue.main.async {
            self.CDs = SMOs
        }
    }
    
    /// Sorting Functions
    ///
    func sortNilDates(channels: [SChannel]) -> [SChannel] {
        let sortedChannels = channels.sorted { (channel1, channel2) -> Bool in
            
            if let date1 = channel1.lastMessageDate,
               let date2 = channel2.lastMessageDate {
                
                return date1 > date2
                
            } else if let date1 = channel1.lastMessageDate,
                      channel2.lastMessageDate==nil {
                
                return date1 > channel2.creationDate
            } else if channel1.lastMessageDate==nil,
                      let date2 = channel2.lastMessageDate {
                
                return channel1.creationDate > date2
                
            } else {
                return channel1.creationDate > channel2.creationDate
            }
        }
        
        return sortedChannels
    }
    
    /// SMO Sync Functions
    ///
    func syncRU(RU: SRemoteUser) {
        DispatchQueue.main.async {
            self.RUs[RU.userID] = RU
        }
    }
    
    func syncChannel(channel: SChannel) {
        DispatchQueue.main.async {
            
            if self.channels.isEmpty {
                self.channels.append(channel)
            }
            
            for (index, currChannel) in self.channels.enumerated() {
                
                if let date1 = channel.lastMessageDate {
                    if let date2 = currChannel.lastMessageDate,
                       date1 > date2 {
                        self.channels.insert(channel, at: index)
                        return
                    } else if date1 > currChannel.creationDate {
                        self.channels.insert(channel, at: index)
                        return
                    }
                } else {
                    if let date2 = currChannel.lastMessageDate,
                       channel.creationDate > date2 {
                        self.channels.insert(channel, at: index)
                        return
                    } else if channel.creationDate > currChannel.creationDate {
                        self.channels.insert(channel, at: index)
                        return
                    }
                }
            }
        }
    }
    
    func syncCR(CR: SChannelRequest) {
        DispatchQueue.main.async {
            if self.CRs.isEmpty {
                self.CRs.append(CR)
            }
            
            for (index, currCR) in self.CRs.enumerated() {
                if CR.date > currCR.date {
                    self.CRs.insert(CR, at: index)
                    return
                }
            }
        }
    }
    
    func syncCD(CD: SChannelDeletion) {
        DispatchQueue.main.async {
            if self.CDs.isEmpty {
                self.CDs.append(CD)
            }
            
            for (index, currCD) in self.CDs.enumerated() {
                if CD.deletionDate > currCD.deletionDate {
                    self.CDs.insert(CD, at: index)
                    return
                }
            }
        }
    }
    
    /// Local Remove Functions
    ///
    func removeRU(userID: String) {
        DispatchQueue.main.async {
            self.RUs.removeValue(forKey: userID)
        }
    }
    
    func removeChannel(channelID: String) {
        DispatchQueue.main.async {
            let channelIndex = self.channels.firstIndex(where: { $0.channelID == channelID })
            if let channelIndex = channelIndex {
                self.channels.remove(at: channelIndex)
            }
        }
    }
    
    func removeCR(requestID: String) {
        DispatchQueue.main.async {
            let CRIndex = self.CRs.firstIndex(where: { $0.requestID == requestID })
            if let CRIndex = CRIndex {
                self.CRs.remove(at: CRIndex)
            }
        }
    }
    
    func removeCD(deletionID: String) {
        DispatchQueue.main.async {
            let CDIndex = self.CDs.firstIndex(where: { $0.deletionID == deletionID })
            if let CDIndex = CDIndex {
                self.CDs.remove(at: CDIndex)
            }
        }
    }
    
    /// Local Delete Functions
    ///
    func deleteRU(userID: String) async throws {
        self.removeRU(userID: userID)
        
        try await DataPC.shared.fetchDeleteMO(entity: RemoteUser.self,
                                              predicateProperty: "userID",
                                              predicateValue: userID)
    }
    
    func deleteChannel(channelID: String) async throws {
        self.removeChannel(channelID: channelID)
        
        try await DataPC.shared.fetchDeleteMO(entity: Channel.self,
                                              predicateProperty: "channelID",
                                              predicateValue: channelID)
    }
    
    func deleteCR(requestID: String) async throws {
        self.removeCR(requestID: requestID)
        
        try await DataPC.shared.fetchDeleteMO(entity: ChannelRequest.self,
                                              predicateProperty: "requestID",
                                              predicateValue: requestID)
    }
    
    func deleteCD(deletionID: String) async throws {
        self.removeCD(deletionID: deletionID)
        
        try await DataPC.shared.fetchDeleteMO(entity: ChannelDeletion.self,
                                              predicateProperty: "deletionID",
                                              predicateValue: deletionID)
    }
    
    /// Local Fetch Functions
    ///
    func fetchRULocally(userID: String) async throws -> SRemoteUser {
        
        let SMO = try await DataPC.shared.fetchSMO(entity: RemoteUser.self,
                                                   predicateProperty: "userID",
                                                   predicateValue: userID)
        return SMO
    }
    
    func fetchChannelLocally(channelID: String) async throws -> SChannel {
        
        let SMO = try await DataPC.shared.fetchSMO(entity: Channel.self,
                                                   predicateProperty: "channelID",
                                                   predicateValue: channelID)
        return SMO
    }
    
    func fetchCRLocally(channelID: String) async throws -> SChannelRequest {
        
        let SMO = try await DataPC.shared.fetchSMO(entity: ChannelRequest.self,
                                                   predicateProperty: "channelID",
                                                   predicateValue: channelID)
        return SMO
    }
    
    func fetchCDLocally(deletionID: String) async throws -> SChannelDeletion {
        
        let SMO = try await DataPC.shared.fetchSMO(entity: ChannelDeletion.self,
                                                   predicateProperty: "deletionID",
                                                   predicateValue: deletionID)
        return SMO
    }
    
    /// Local Event Functions
    ///
    func deleteUserTrace(userID: String,
                         deletionDate: Date = DateU.shared.currDT) async throws {
        
        let RU: SRemoteUser
        
        if let user = self.RUs[userID] {
            RU = user
        } else {
            RU = try await DataPC.shared.fetchSMO(entity: RemoteUser.self,
                                                  predicateProperty: "userID",
                                                  predicateValue: userID)
        }
        
        try await DataPC.shared.fetchDeleteMOs(entity: RemoteUser.self,
                                               predicateProperty: "userID",
                                               predicateValue: userID)
        self.removeRU(userID: userID)
        
        let channel = try await DataPC.shared.fetchSMO(entity: Channel.self,
                                                       predicateProperty: "userID",
                                                       predicateValue: userID)
        
        try await DataPC.shared.fetchDeleteMOs(entity: Channel.self,
                                               predicateProperty: "userID",
                                               predicateValue: userID)
        self.removeChannel(channelID: channel.channelID)
        
        try await MessageDC.shared.deleteChannelMessages(channelID: channel.channelID)
        
        let SCD = try await DataPC.shared.createCD(deletionID: UUID().uuidString,
                                                   channelType: "RU",
                                                   deletionDate: deletionDate,
                                                   type: "delete",
                                                   name: RU.username,
                                                   icon: RU.avatar,
                                                   nUsers: 1,
                                                   isOrigin: false)
        self.syncCD(CD: SCD)
    }
    
    func clearChannelData(channelID: String,
                          RU: SRemoteUser? = nil,
                          deletionDate: Date = DateU.shared.currDT,
                          isOrigin: Bool) async throws -> SChannelDeletion {
        
        if channelID == "personal" {
            try await MessageDC.shared.clearChannelMessages(channelID: channelID)
            
            let SCD = try await DataPC.shared.createCD(deletionID: UUID().uuidString,
                                                       channelType: "personal",
                                                       deletionDate: deletionDate,
                                                       type: "clear",
                                                       name: UserDC.shared.userData!.username,
                                                       icon: UserDC.shared.userData!.avatar,
                                                       nUsers: 1,
                                                       isOrigin: isOrigin)
            return SCD
        } else if let RU = RU {
            try await MessageDC.shared.clearChannelMessages(channelID: channelID)
            
            let SCD = try await DataPC.shared.createCD(deletionID: UUID().uuidString,
                                                       channelType: "RU",
                                                       deletionDate: deletionDate,
                                                       type: "clear",
                                                       name: RU.username,
                                                       icon: RU.avatar,
                                                       nUsers: 1,
                                                       isOrigin: isOrigin)
            return SCD
        } else {
            throw DCError.clientFailure(func: "ChannelDC.clearChannelData", err: "RU is nil for non-personal channel")
        }
    }
    
    func deleteChannelData(channelID: String,
                           RU: SRemoteUser,
                           deletionDate: Date = DateU.shared.currDT,
                           isOrigin: Bool) async throws -> SChannelDeletion {
        
        if channelID != "personal" {
            try await MessageDC.shared.deleteChannelMessages(channelID: channelID)
            
            let SCD = try await DataPC.shared.createCD(deletionID: UUID().uuidString,
                                                       channelType: "RU",
                                                       deletionDate: deletionDate,
                                                       type: "delete",
                                                       name: RU.username,
                                                       icon: RU.avatar,
                                                       nUsers: 1,
                                                       isOrigin: isOrigin)
            return SCD
        } else {
            throw DCError.invalidRequest(func: "ChannelDC.deleteChannelData", err: "cannot delete personal channel")
        }
        
    }
    
}
