//
//  ChannelDC+Local.swift
//  bluezebra
//
//  Created by Harshel Bahl on 19/04/2023.
//

import Foundation

extension ChannelDC {
    
    
    /// Local Create Functions
    ///
    func createChannel(channelID: String = UUID().uuidString,
                       userID: String,
                       creationDate: Date = DateU.shared.currDT) async throws {
        
        let SChannel = try await DataPC.shared.createChannel(channelID: channelID,
                                                             userID: userID,
                                                             creationDate: creationDate)
        
        try await DataPC.shared.createChannelDir(channelID: channelID)
        
        self.syncChannel(channel: SChannel)
    }
    
    
    /// Local Sync Functions
    ///
    func syncAllData() async throws {
        try await self.syncPersonalChannel()
        try await self.syncRUChannels(fetchLimit: 20)
        try await self.syncCRs(fetchLimit: 20)
        try await self.syncCDs(fetchLimit: 20)
    }
    
    func syncPersonalChannel() async throws {
        let SMO = try await DataPC.shared.fetchSMO(entity: Channel.self,
                                                   predicateProperty: "channelID",
                                                   predicateValue: "personal")
        DispatchQueue.main.async {
            self.personalChannel = SMO
        }
    }
    
    func syncRUChannels(fetchLimit: Int? = nil) async throws {
        
        if RUChannels.isEmpty {
            let predicate = NSPredicate(format: "channelID != %@", argumentArray: ["personal"])
            
            let SMOs = try await DataPC.shared.fetchSMOs(entity: Channel.self,
                                                         customPredicate: predicate,
                                                         fetchLimit: fetchLimit,
                                                         sortKey: "lastMessageDate")
            
            let sortedSMOs = self.sortNilDates(channels: SMOs)
            
            DispatchQueue.main.async {
                self.RUChannels = sortedSMOs
            }
        } else {
            if let earliestDate = self.RUChannels.last?.lastMessageDate {
                let predicate = NSPredicate(format: "channelID != %@ AND lastMessageDate < %@", argumentArray: ["personal", earliestDate])
                
                let SMOs = try await DataPC.shared.fetchSMOs(entity: Channel.self,
                                                             customPredicate: predicate,
                                                             fetchLimit: fetchLimit,
                                                             sortKey: "lastMessageDate")
                
                let sortedSMOs = self.sortNilDates(channels: SMOs)
                
                DispatchQueue.main.async {
                    self.RUChannels.append(contentsOf: sortedSMOs)
                }
            } else {
                guard let earliestDate = self.RUChannels.last?.creationDate else { return }
                
                let predicate = NSPredicate(format: "channelID != %@ AND lastMessageDate < %@", argumentArray: ["personal", earliestDate])
                
                let SMOs = try await DataPC.shared.fetchSMOs(entity: Channel.self,
                                                             customPredicate: predicate,
                                                             fetchLimit: fetchLimit,
                                                             sortKey: "lastMessageDate")
                
                let sortedSMOs = self.sortNilDates(channels: SMOs)
                
                DispatchQueue.main.async {
                    self.RUChannels.append(contentsOf: sortedSMOs)
                }
            }
        }
    }
    
    func syncCRs(fetchLimit: Int? = nil) async throws {
        
        if self.CRs.isEmpty {
            let SMOs = try await DataPC.shared.fetchSMOs(entity: ChannelRequest.self,
                                                         fetchLimit: fetchLimit,
                                                         sortKey: "date")
            
            DispatchQueue.main.async {
                self.CRs = SMOs
            }
        } else {
            guard let earliestCR = self.CRs.sorted(by: { (CR1, CR2) -> Bool in
                return CR1.date > CR2.date
            }).last else { return }
            
            let earliestDate = earliestCR.date
            
            let predicate = NSPredicate(format: "date < %@", argumentArray: [earliestDate])
            
            let SMOs = try await DataPC.shared.fetchSMOs(entity: ChannelRequest.self,
                                                         customPredicate: predicate,
                                                         fetchLimit: fetchLimit,
                                                         sortKey: "date")
            
            DispatchQueue.main.async {
                self.CRs.append(contentsOf: SMOs)
            }
        }
    }
    
    
    func syncCDs(fetchLimit: Int? = nil) async throws {
        
        if self.CDs.isEmpty {
            let SMOs = try await DataPC.shared.fetchSMOs(entity: ChannelDeletion.self,
                                                         fetchLimit: fetchLimit,
                                                         sortKey: "deletionDate")
            
            DispatchQueue.main.async {
                self.CDs = SMOs
            }
        } else {
            guard let earliestCD = self.CDs.sorted(by: { (CD1, CD2) -> Bool in
                return CD1.deletionDate > CD2.deletionDate
            }).last else { return }
            
            let earliestDate = earliestCD.deletionDate
            
            let predicate = NSPredicate(format: "deletionDate < %@", argumentArray: [earliestDate])
            
            let SMOs = try await DataPC.shared.fetchSMOs(entity: ChannelDeletion.self,
                                                         customPredicate: predicate,
                                                         fetchLimit: fetchLimit,
                                                         sortKey: "deletionDate")
            
            DispatchQueue.main.async {
                self.CDs.append(contentsOf: SMOs)
            }
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
    func syncChannel(channel: SChannel) {
        DispatchQueue.main.async {
            
            if let index = self.RUChannels.firstIndex(where: { $0.channelID == channel.channelID }) {
                self.RUChannels.remove(at: index)
            }
            
            if self.RUChannels.isEmpty {
                self.RUChannels.append(channel)
            }
            
            for (index, currChannel) in self.RUChannels.enumerated() {
                
                if let date1 = channel.lastMessageDate {
                    if let date2 = currChannel.lastMessageDate,
                       date1 > date2 {
                        self.RUChannels.insert(channel, at: index)
                        return
                    } else if date1 > currChannel.creationDate {
                        self.RUChannels.insert(channel, at: index)
                        return
                    }
                } else {
                    if let date2 = currChannel.lastMessageDate,
                       channel.creationDate > date2 {
                        self.RUChannels.insert(channel, at: index)
                        return
                    } else if channel.creationDate > currChannel.creationDate {
                        self.RUChannels.insert(channel, at: index)
                        return
                    }
                }
            }
        }
    }
    
    func syncCR(CR: SChannelRequest) {
        DispatchQueue.main.async {
            
            if let index = self.CRs.firstIndex(where: { $0.requestID == CR.requestID }) {
                self.CRs.remove(at: index)
            }
            
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
            
            if let index = self.CDs.firstIndex(where: { $0.deletionID == CD.deletionID }) {
                self.CDs.remove(at: index)
            }
            
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
    
    func syncRU(RU: SRemoteUser) {
        DispatchQueue.main.async {
            self.RUs[RU.userID] = RU
        }
    }
    
    
    /// Local Remove Functions
    ///
    func removeChannel(channelID: String) {
        DispatchQueue.main.async {
            let channelIndex = self.RUChannels.firstIndex(where: { $0.channelID == channelID })
            
            if let channelIndex = channelIndex {
                self.RUChannels.remove(at: channelIndex)
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
        try await DataPC.shared.fetchDeleteMO(entity: RemoteUser.self,
                                              predicateProperty: "userID",
                                              predicateValue: userID)
    }
    
    func deleteChannel(channelID: String) async throws {
        self.removeChannel(channelID: channelID)
        
        try await DataPC.shared.fetchDeleteMO(entity: Channel.self,
                                              predicateProperty: "channelID",
                                              predicateValue: channelID)
        
        try await DataPC.shared.removeDir(dir: channelID)
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
    
    /// SMO Fetch Functions
    ///
    func fetchRUOffOn(userID: String) async throws -> SRemoteUser {
        
        if let RU = try? await self.fetchRULocally(userID: userID) {
            return RU
        } else {
            let RUPacket = try await self.fetchRU(userID: userID)
            
            let SRU = try await DataPC.shared.createRU(userID: RUPacket.userID,
                                                       username: RUPacket.username,
                                                       avatar: RUPacket.avatar,
                                                       creationDate: try DateU.shared.dateFromStringTZ(RUPacket.creationDate))
            return SRU
        }
    }
    
    /// Local Check Functions
    ///
    func checkChannelDir(channelID: String,
                         dirs: [String] = ["images", "files"]) async throws {
        for dir in dirs {
            do {
                let dirCheck = DataPC.shared.checkDir(dir: dir,
                                                      intermidDirs: [channelID])
                
                guard dirCheck else { throw DCError.fileSystemFailure( err: "channelID: \(channelID), dir: \(dir)") }
                
            } catch {
                
                try await DataPC.shared.createDir(dir: dir,
                                                  intermidDirs: [channelID])
            }
        }
    }
    
    
    /// Local Event Functions
    ///
    func clearChannelData(channelID: String,
                          RU: SRemoteUser? = nil,
                          deletionID: String = UUID().uuidString,
                          deletionDate: Date = DateU.shared.currDT,
                          isOrigin: Bool) async throws -> SChannelDeletion {
        
        if channelID == "personal" {
            try await MessageDC.shared.clearChannelMessages(channelID: channelID)
            
            let SCD = try await DataPC.shared.createCD(deletionID: deletionID,
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
            
            let SCD = try await DataPC.shared.createCD(deletionID: deletionID,
                                                       channelType: "RU",
                                                       deletionDate: deletionDate,
                                                       type: "clear",
                                                       name: RU.username,
                                                       icon: RU.avatar,
                                                       nUsers: 1,
                                                       toDeleteUserIDs: [RU.userID],
                                                       isOrigin: isOrigin)
            return SCD
        } else {
            throw DCError.nilError(err: "RU is nil for non-personal channel")
        }
    }
    
    func deleteChannelData(channelID: String,
                           RU: SRemoteUser,
                           deletionID: String = UUID().uuidString,
                           deletionDate: Date = DateU.shared.currDT,
                           isOrigin: Bool) async throws -> SChannelDeletion {
        
        if channelID != "personal" {
            try await self.deleteChannel(channelID: channelID)
            
            try await MessageDC.shared.deleteChannelMessages(channelID: channelID)
            
            if let RU = try? await self.fetchRULocally(userID: RU.userID) {
                try await self.deleteRU(userID: RU.userID)
            }
            
            let SCD = try await DataPC.shared.createCD(deletionID: deletionID,
                                                       channelType: "RU",
                                                       deletionDate: deletionDate,
                                                       type: "delete",
                                                       name: RU.username,
                                                       icon: RU.avatar,
                                                       nUsers: 1,
                                                       toDeleteUserIDs: [RU.userID],
                                                       isOrigin: isOrigin)
            return SCD
        } else {
            throw DCError.invalidRequest(err: "cannot delete personal channel")
        }
    }
    
    func deleteUserTrace(userID: String,
                         deletionDate: Date = DateU.shared.currDT) async throws {
        
        let RU: SRemoteUser?
        
        do {
            RU = try await self.fetchRUOffOn(userID: userID)
        } catch {
            RU = nil
        }
        
        if let RU = RU {
            if let channel = try? await DataPC.shared.fetchSMO(entity: Channel.self,
                                                               predicateProperty: "userID",
                                                               predicateValue: userID) {
                
                let SCD = try await self.deleteChannelData(channelID: channel.channelID,
                                                           RU: RU,
                                                           deletionDate: deletionDate,
                                                           isOrigin: false)
                self.syncCD(CD: SCD)
            }
            
            try? await self.deleteRU(userID: RU.userID)
        } else {
            if let channel = try? await DataPC.shared.fetchSMO(entity: Channel.self,
                                                               predicateProperty: "userID",
                                                               predicateValue: userID) {
                
                try await self.deleteChannel(channelID: channel.channelID)
                
                try await MessageDC.shared.deleteChannelMessages(channelID: channel.channelID)
            }
            
            try? await DataPC.shared.fetchDeleteMO(entity: ChannelRequest.self,
                                                   predicateProperty: "userID",
                                                   predicateValue: userID)
        }
    }
    
    func offline() {
        DispatchQueue.main.async {
            self.onlineUsers = [String: Bool]()
        }
    }
    
    func shutdown() {
        DispatchQueue.main.async {
            self.onlineUsers = [String: Bool]()
        }
    }
    
    func resetState(keepPersonalChannel: Bool = false) {
        DispatchQueue.main.async {
            if !keepPersonalChannel { self.personalChannel = nil }
            
            self.RUChannels = [SChannel]()
            
            self.onlineUsers = [String: Bool]()
            
            self.CRs = [SChannelRequest]()
            self.CDs = [SChannelDeletion]()
        }
    }
}
