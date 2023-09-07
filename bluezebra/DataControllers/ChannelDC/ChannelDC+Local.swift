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
    func createRUChannel(channelID: UUID = UUID(),
                       uID: UUID,
                       creationDate: Date = DateU.shared.currDT) async throws {
        
        let SChannel = try await DataPC.shared.backgroundPerformSync() {
            
            let RUMO = try DataPC.shared.fetchMO(entity: RemoteUser.self,
                                                       predObject: ["uID": uID])
            
            let channelMO = try DataPC.shared.createChannel(channelID: channelID,
                                                            uID: uID,
                                                            channelType: "RU",
                                                            creationDate: creationDate,
            remoteUser: RUMO)
            
            return try channelMO.safeObject()
        }
        
        try await DataPC.shared.createChannelDir(channelID: channelID.uuidString)
        
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
                                                   predObject: ["channelID": "personal"])
        DispatchQueue.main.async {
            self.personalChannel = SMO
        }
    }
    
    func syncRUChannels(fetchLimit: Int? = nil) async throws {
        
        if RUChannels.isEmpty {
            let SMOs = try await DataPC.shared.fetchSMOs(entity: Channel.self,
                                                         predObjectNotEqual: ["channelID": "personal"],
                                                         fetchLimit: fetchLimit,
                                                         sortKey: "lastMessageDate")
            
            let sortedSMOs = self.sortNilDates(channels: SMOs)
            
            DispatchQueue.main.async {
                self.RUChannels = sortedSMOs
            }
        } else {
            if let earliestDate = self.RUChannels.last?.lastMessageDate {
                
                let SMOs = try await DataPC.shared.fetchSMOs(entity: Channel.self,
                                                             predObjectNotEqual: ["channelID": "personal"],
                                                             datePredicates: [DataPC.DatePredicate(key: "lastMessageDate", date: earliestDate, isAbove: false)],
                                                             fetchLimit: fetchLimit,
                                                             sortKey: "lastMessageDate")
                
                let sortedSMOs = self.sortNilDates(channels: SMOs)
                
                DispatchQueue.main.async {
                    self.RUChannels.append(contentsOf: sortedSMOs)
                }
            } else {
                guard let earliestDate = self.RUChannels.last?.creationDate else { return }
                
                let SMOs = try await DataPC.shared.fetchSMOs(entity: Channel.self,
                                                             predObjectNotEqual: ["channelID": "personal"],
                                                             datePredicates: [DataPC.DatePredicate(key: "lastMessageDate", date: earliestDate, isAbove: false)],
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
            
            let SMOs = try await DataPC.shared.fetchSMOs(entity: ChannelRequest.self,
                                                         datePredicates: [DataPC.DatePredicate(key: "date", date: earliestDate, isAbove: false)],
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
            
            let SMOs = try await DataPC.shared.fetchSMOs(entity: ChannelDeletion.self,
                                                         datePredicates: [DataPC.DatePredicate(key: "deletionDate", date: earliestDate, isAbove: false)],
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
            self.RUs[RU.uID] = RU
        }
    }
    
    
    /// Local Remove Functions
    ///
    func removeChannel(channelID: UUID) {
        DispatchQueue.main.async {
            let channelIndex = self.RUChannels.firstIndex(where: { $0.channelID == channelID })
            
            if let channelIndex = channelIndex {
                self.RUChannels.remove(at: channelIndex)
            }
        }
    }
    
    func removeCR(requestID: UUID) {
        DispatchQueue.main.async {
            let CRIndex = self.CRs.firstIndex(where: { $0.requestID == requestID })
            
            if let CRIndex = CRIndex {
                self.CRs.remove(at: CRIndex)
            }
        }
    }
    
    func removeCD(deletionID: UUID) {
        DispatchQueue.main.async {
            let CDIndex = self.CDs.firstIndex(where: { $0.deletionID == deletionID })
            
            if let CDIndex = CDIndex {
                self.CDs.remove(at: CDIndex)
            }
        }
    }
    
    
    /// Local Delete Functions
    ///
    func deleteRU(uID: UUID) async throws {
        try await DataPC.shared.backgroundPerformSync() {
            try DataPC.shared.deleteMO(entity: RemoteUser.self,
                                             predObject: ["uID": uID])
        }
    }
    
    func deleteChannel(channelID: UUID) async throws {
        self.removeChannel(channelID: channelID)
        
        try await DataPC.shared.backgroundPerformSync() {
            try DataPC.shared.deleteMO(entity: Channel.self,
                                       predObject: ["channelID": channelID])
        }
        
        try await DataPC.shared.removeDir(dir: channelID.uuidString)
    }
    
    func deleteCR(requestID: UUID) async throws {
        self.removeCR(requestID: requestID)
        
        try await DataPC.shared.backgroundPerformSync() {
            try DataPC.shared.deleteMO(entity: ChannelRequest.self,
                                       predObject: ["requestID": requestID])
        }
    }
    
    func deleteCD(deletionID: UUID) async throws {
        self.removeCD(deletionID: deletionID)
        
        try await DataPC.shared.backgroundPerformSync() {
            try DataPC.shared.deleteMO(entity: ChannelDeletion.self,
                                       predObject: ["deletionID": deletionID])
        }
    }
    
    
    /// Local Fetch Functions
    ///
    func fetchRULocally(uID: UUID) async throws -> SRemoteUser {
        
        let SMO = try await DataPC.shared.fetchSMO(entity: RemoteUser.self,
                                                   predObject: ["uID": uID])
        return SMO
    }
    
    func fetchChannelLocally(channelID: UUID) async throws -> SChannel {
        
        let SMO = try await DataPC.shared.fetchSMO(entity: Channel.self,
                                                   predObject: ["channelID": channelID])
        
        return SMO
    }
    
    func fetchCRLocally(channelID: UUID) async throws -> SChannelRequest {
        
        let SMO = try await DataPC.shared.fetchSMO(entity: ChannelRequest.self,
                                                   predObject: ["channelID": channelID])
        
        return SMO
    }
    
    func fetchCDLocally(deletionID: UUID) async throws -> SChannelDeletion {
        
            let SMO = try await DataPC.shared.fetchSMO(entity: ChannelDeletion.self,
                                                       predObject: ["deletionID": deletionID])
        
        return SMO
    }
    
    /// SMO Fetch Functions
    ///
    func fetchRUOffOn(uID: UUID) async throws -> SRemoteUser {
        
        if let RU = try? await self.fetchRULocally(uID: uID) {
            return RU
        } else {
            let RUPacket = try await self.fetchRU(uID: uID)
            
            let SRU = try await DataPC.shared.backgroundPerformSync() {
                let RUMO = try DataPC.shared.createRU(uID: RUPacket.uID,
                                           username: RUPacket.username,
                                           avatar: RUPacket.avatar,
                                           creationDate: try DateU.shared.dateFromStringTZ(RUPacket.creationDate))
                
                return try RUMO.safeObject()
            }
            
            return SRU
        }
    }
    
    /// Local Check Functions
    ///
    func checkChannelDir(channelID: UUID,
                         dirs: [String] = ["images", "files"]) async throws {
        for dir in dirs {
            do {
                let dirCheck = DataPC.shared.checkDir(dir: dir,
                                                      intermidDirs: [channelID.uuidString])
                
                guard dirCheck else { throw DCError.fileSystemFailure( err: "channelID: \(channelID.uuidString), dir: \(dir)") }
                
            } catch {
                try await DataPC.shared.createDir(dir: dir,
                                                  intermidDirs: [channelID.uuidString])
            }
        }
    }
    
    
    /// Local Event Functions
    ///
    func clearChannelData(channel: SChannel,
                          RU: SRemoteUser? = nil,
                          deletionID: UUID = UUID(),
                          deletionDate: Date = DateU.shared.currDT,
                          isOrigin: Bool) async throws -> SChannelDeletion {
        
        if channel.channelType == "personal" {
            try await MessageDC.shared.clearChannelMessages(channelID: channel.channelID)
            
            let SCD = try await DataPC.shared.backgroundPerformSync() {
                let CDMO = try DataPC.shared.createCD(deletionID: deletionID,
                                                      channelType: channel.channelType,
                                                     deletionDate: deletionDate,
                                                     type: "clear",
                                                     name: UserDC.shared.userdata!.username,
                                                     icon: UserDC.shared.userdata!.avatar,
                                                     nUsers: 1,
                                                     isOrigin: isOrigin)
                return try CDMO.safeObject()
            }
            
            return SCD
        } else if let RU = RU {
            try await MessageDC.shared.clearChannelMessages(channelID: channel.channelID)
            
            let SCD = try await DataPC.shared.backgroundPerformSync() {
                let CDMO = try DataPC.shared.createCD(deletionID: deletionID,
                                                      channelType: channel.channelType,
                                                     deletionDate: deletionDate,
                                                     type: "clear",
                                                     name: RU.username,
                                                     icon: RU.avatar,
                                                     nUsers: 1,
                                                      toDeleteUIDs: [RU.uID],
                                                     isOrigin: isOrigin)
                return try CDMO.safeObject()
            }
            
            return SCD
        } else {
            throw DCError.nilError(err: "RU is nil for non-personal channel")
        }
    }
    
    func deleteChannelData(channel: SChannel,
                           RU: SRemoteUser,
                           deletionID: UUID = UUID(),
                           deletionDate: Date = DateU.shared.currDT,
                           isOrigin: Bool) async throws -> SChannelDeletion {
        
        if channel.channelType != "personal" {
            try await self.deleteChannel(channelID: channel.channelID)
            
            try await MessageDC.shared.deleteChannelMessages(channelID: channel.channelID)
            
            if let RU = try? await self.fetchRULocally(uID: RU.uID) {
                try await self.deleteRU(uID: RU.uID)
            }
            
            let SCD = try await DataPC.shared.backgroundPerformSync() {
                let CDMO = try DataPC.shared.createCD(deletionID: deletionID,
                                                      channelType: channel.channelType,
                                                     deletionDate: deletionDate,
                                                     type: "delete",
                                                     name: RU.username,
                                                     icon: RU.avatar,
                                                     nUsers: 1,
                                                      toDeleteUIDs: [RU.uID],
                                                     isOrigin: isOrigin)
                return try CDMO.safeObject()
            }
            
            return SCD
        } else {
            throw DCError.invalidRequest(err: "cannot delete personal channel")
        }
    }
    
    func deleteUserTrace(uID: UUID,
                         deletionDate: Date = DateU.shared.currDT) async throws {
        
        let RU: SRemoteUser?
        
        do {
            RU = try await self.fetchRUOffOn(uID: uID)
        } catch {
            RU = nil
        }
        
        if let RU = RU {
            if let channel = try? await DataPC.shared.fetchSMO(entity: Channel.self,
                                                               predObject: ["uID": uID]) {
                
                let SCD = try await self.deleteChannelData(channel: channel,
                                                           RU: RU,
                                                           deletionDate: deletionDate,
                                                           isOrigin: false)
                self.syncCD(CD: SCD)
            }
            
            try? await self.deleteRU(uID: RU.uID)
        } else {
            if let channel = try? await DataPC.shared.fetchSMO(entity: Channel.self,
                                                               predObject: ["uID": uID]) {
                
                try await self.deleteChannel(channelID: channel.channelID)
                
                try await MessageDC.shared.deleteChannelMessages(channelID: channel.channelID)
            }
            
            try await DataPC.shared.backgroundPerformSync() {
                try? DataPC.shared.deleteMO(entity: ChannelRequest.self,
                                                  predObject: ["uID": uID])
            }
        }
    }
    
    func offline() {
        DispatchQueue.main.async {
            self.onlineUsers = [UUID: Bool]()
        }
    }
    
    func shutdown() {
        DispatchQueue.main.async {
            self.onlineUsers = [UUID: Bool]()
        }
    }
    
    func resetState(keepPersonalChannel: Bool = false) {
        DispatchQueue.main.async {
            if !keepPersonalChannel { self.personalChannel = nil }
            
            self.RUChannels = [SChannel]()
            
            self.onlineUsers = [UUID: Bool]()
            
            self.CRs = [SChannelRequest]()
            self.CDs = [SChannelDeletion]()
        }
    }
}
