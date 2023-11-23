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
        try await self.syncPersonalChannel()
        try await self.syncRUChannels(fetchLimit: 20)
        try await self.syncCRs(fetchLimit: 20)
        try await self.syncCDs(fetchLimit: 20)
    }
    
    func syncPersonalChannel() async throws {
        let SMO = try await DataPC.shared.fetchSMO(entity: Channel.self,
                                                   predDicEqual: ["channelType": "personal"])
        DispatchQueue.main.async {
            self.personalChannel = SMO
        }
    }
    
    func syncRUChannels(fetchLimit: Int? = nil) async throws {
        
        if RUChannels.isEmpty {
            let SMOs = try await DataPC.shared.fetchSMOs(entity: Channel.self,
                                                         predDicNotEqual: ["channelType": "personal"],
                                                         fetchLimit: fetchLimit,
                                                         sortKey: "lastMessageDate")
            
            let sortedSMOs = self.sortNilDates(channels: SMOs)
            
            DispatchQueue.main.async {
                self.RUChannels = sortedSMOs
            }
        } else {
            if let earliestDate = self.RUChannels.last?.lastMessageDate {
                
                let SMOs = try await DataPC.shared.fetchSMOs(entity: Channel.self,
                                                             predDicNotEqual: ["channelType": "personal"],
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
                                                             predDicNotEqual: ["channelType": "personal"],
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
    func syncPersonalChannel(personalChannel: SChannel) {
        DispatchQueue.main.async {
            self.personalChannel = personalChannel
        }
    }
    
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
    func removeRU(uID: UUID) {
        DispatchQueue.main.async {
            if self.RUs.keys.contains(uID) {
                self.RUs.removeValue(forKey: uID)
            }
        }
    }
    
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
        self.removeRU(uID: uID)
        
        try await DataPC.shared.backgroundPerformSync() {
            try DataPC.shared.deleteMO(entity: RemoteUser.self,
                                             predDicEqual: ["uID": uID])
        }
    }
    
    func deleteChannel(channelID: UUID) async throws {
        self.removeChannel(channelID: channelID)
        
        try await DataPC.shared.backgroundPerformSync() {
            try DataPC.shared.deleteMO(entity: Channel.self,
                                       predDicEqual: ["channelID": channelID])
        }
        
        try await DataPC.shared.removeDir(dir: channelID.uuidString)
    }
    
    func deleteCR(requestID: UUID) async throws {
        self.removeCR(requestID: requestID)
        
        try await DataPC.shared.backgroundPerformSync() {
            try DataPC.shared.deleteMO(entity: ChannelRequest.self,
                                       predDicEqual: ["requestID": requestID])
        }
    }
    
    func deleteCD(deletionID: UUID) async throws {
        self.removeCD(deletionID: deletionID)
        
        try await DataPC.shared.backgroundPerformSync() {
            try DataPC.shared.deleteMO(entity: ChannelDeletion.self,
                                       predDicEqual: ["deletionID": deletionID])
        }
    }
    
    
    /// Local Fetch Functions
    ///
    func fetchRULocally(uID: UUID) async throws -> SRemoteUser {
        
        let SMO = try await DataPC.shared.fetchSMO(entity: RemoteUser.self,
                                                   predDicEqual: ["uID": uID])
        return SMO
    }
    
    func fetchChannelLocally(channelID: UUID) async throws -> SChannel {
        
        let SMO = try await DataPC.shared.fetchSMO(entity: Channel.self,
                                                   predDicEqual: ["channelID": channelID])
        
        return SMO
    }
    
    func fetchCRLocally(channelID: UUID) async throws -> SChannelRequest {
        
        let SMO = try await DataPC.shared.fetchSMO(entity: ChannelRequest.self,
                                                   predDicEqual: ["channelID": channelID])
        
        return SMO
    }
    
    func fetchCDLocally(deletionID: UUID) async throws -> SChannelDeletion {
        
            let SMO = try await DataPC.shared.fetchSMO(entity: ChannelDeletion.self,
                                                       predDicEqual: ["deletionID": deletionID])
        
        return SMO
    }
    
    /// SMO Fetch Functions
    ///
    func fetchRUOffOn(uID: UUID) async throws -> SRemoteUser {
        
        if let RU = try? await self.fetchRULocally(uID: uID) {
            return RU
        } else {
            let RUP = try await self.fetchRUP(uID: uID)
            
            let SRU = try await DataPC.shared.backgroundPerformSync() {
                
                
                let RUMO = try DataPC.shared.createRU(uID: RUP.uID,
                                                      username: RUP.username,
                                                      publicKey: RUP.publicKey,
                                                      avatar: RUP.avatar,
                                                      creationDate: RUP.creationDate,
                                                      lastOnline: RUP.lastOnline)
                
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
    func createCR(requestID: UUID,
                  requestDate: Date,
                  RU: RUP) async throws -> (SRemoteUser, SChannelRequest) {
        do {
            let (SRU, SCR) = try await DataPC.shared.backgroundPerformSync() {
                
                let RUMO = try DataPC.shared.createRU(uID: RU.uID,
                                                      username: RU.username,
                                                      publicKey: RU.publicKey,
                                                      avatar: RU.avatar,
                                                      creationDate: RU.creationDate,
                                                      lastOnline: RU.lastOnline)
                
                let CRMO = try DataPC.shared.createCR(requestID: requestID,
                                                      uID: RU.uID,
                                                      date: requestDate,
                                                      isSender: false,
                                                      remoteUser: RUMO)
                
                return (try RUMO.safeObject(), try CRMO.safeObject())
            }
            
            log.debug(message: "successfully created CR locally", function: "ChannelDC.createCR")
            
            return (SRU, SCR)
        } catch {
            log.debug(message: "failed to create CR locally", function: "ChannelDC.createCR", error: error)
            throw error
        }
    }
    
    func createRUChannel(channelID: UUID = UUID(),
                         uID: UUID,
                         creationDate: Date = DateU.shared.currDT) async throws {
        
        let SChannel = try await DataPC.shared.backgroundPerformSync() {
            
            let RUMO = try DataPC.shared.fetchMO(entity: RemoteUser.self,
                                                 predDicEqual: ["uID": uID])
            
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
    
    func createRUChannelFromCR(requestID: UUID) async throws {
        
    }
    
    func clearChannelData(channelID: UUID,
                          channelType: String,
                          deletionID: UUID = UUID(),
                          deletionDate: Date = DateU.shared.currDT,
                          isOrigin: Bool) async throws {
        
//        try await MessageDC.shared.clearChannelMessages(channelID: channelID)
        
        if channelType == "personal" {
            
            let (SChannel, SCD) = try await DataPC.shared.backgroundPerformSync() {
                
                let channelMO = try DataPC.shared.updateMO(entity: Channel.self,
                                                           property: ["lastMessageDate"],
                                                           value: [DateU.shared.currDT],
                                                           predDicEqual: ["channelID": channelID])
                
                let CDMO = try DataPC.shared.createCD(deletionID: deletionID,
                                                      channelType: channelType,
                                                     deletionDate: deletionDate,
                                                     type: "clear",
                                                     name: UserDC.shared.userdata!.username,
                                                     icon: UserDC.shared.userdata!.avatar,
                                                     nUsers: 1,
                                                      toDeleteUID: [],
                                                     isOrigin: isOrigin)
                return (try channelMO.safeObject(), try CDMO.safeObject())
            }
            
            self.syncChannel(channel: SChannel)
            self.syncCD(CD: SCD)
            
        } else if channelType == "RU" {
            
            let (SChannel, SCD) = try await DataPC.shared.backgroundPerformSync() {
                
                let channelMO = try DataPC.shared.updateMO(entity: Channel.self,
                                                           property: ["lastMessageDate"],
                                                           value: [DateU.shared.currDT],
                                                           predDicEqual: ["channelID": channelID])
                
                let CDMO = try DataPC.shared.createCD(deletionID: deletionID,
                                                      channelType: channelType,
                                                      deletionDate: deletionDate,
                                                      type: "clear",
                                                      name: channelMO.remoteUser!.username,
                                                      icon: channelMO.remoteUser!.avatar,
                                                      nUsers: 1,
                                                      toDeleteUID: [channelMO.uID],
                                                      isOrigin: isOrigin)
                
                return (try channelMO.safeObject(), try CDMO.safeObject())
            }
        } else {
            throw DCError.invalidRequest(err: "channelType isn't specified")
        }
    }
    
//    func deleteChannelData(channelID: UUID,
//                           channelType: String,
//                           removeRU: Bool = true,
//                           deletionID: UUID = UUID(),
//                           deletionDate: Date = DateU.shared.currDT,
//                           isOrigin: Bool) async throws -> SChannelDeletion {
//
//        if channelType != "personal" {
//            try await self.deleteChannel(channelID: channelID)
//
////            try await MessageDC.shared.deleteChannelMessages(channelID: channelID)
//
//            let SCD = try await DataPC.shared.backgroundPerformSync() {
//
//                let channelMO = try DataPC.shared.fetchMO(entity: Channel.self,
//                                                          predDicEqual: ["channelID": channelID])
//
//                let RUMO = channelMO.remoteUser
//
//                let CDMO = try DataPC.shared.createCD(deletionID: deletionID,
//                                                      channelType: channelType,
//                                                      deletionDate: deletionDate,
//                                                      type: "delete",
//                                                      name: RUMO.username,
//                                                      icon: RUMO.avatar,
//                                                      nUsers: 1,
//                                                      isOrigin: isOrigin)
//
//                try DataPC.shared.deleteMO(entity: Channel.self,
//                                           predDicEqual: ["channelID": channelID])
//
//                if removeRU {
//                    try DataPC.shared.deleteMO(entity: RemoteUser.self,
//                                               predDicEqual: ["uID": RUMO.uID])
//                }
//
//                return try CDMO.safeObject()
//            }
//
//            self.syncCD(CD: SCD)
//
//        } else {
//            throw DCError.invalidRequest(err: "cannot delete personal channel")
//        }
//    }
    
    func deleteUserTrace(uID: UUID,
                         deletionDate: Date = DateU.shared.currDT) async throws {
        
        var SChannel: SChannel?
        var SCR: SChannelRequest?
        
        try await DataPC.shared.backgroundPerformSync() {
            
            let RUMO = try DataPC.shared.fetchMO(entity: RemoteUser.self,
                                                 predDicEqual: ["uID": uID])
            
            SChannel = try RUMO.channel?.safeObject()
            SCR = try RUMO.channelRequest?.safeObject()
            
            try DataPC.shared.deleteMO(entity: RemoteUser.self,
                                        predDicEqual: ["uID": uID])
        }
        
        if let SChannel = SChannel {
//            try await MessageDC.shared.deleteChannelMessages(channelID: SChannel.channelID)
            
            self.removeChannel(channelID: SChannel.channelID)
        }
        
        if let SCR = SCR {
            self.removeCR(requestID: SCR.requestID)
        }
    }
    
    func offline() {
        DispatchQueue.main.async {
            self.onlineUsers = [:]
            
            self.serverRUChannelSync = false
            self.serverCRSync = false
        }
    }
    
    func shutdown() {
        DispatchQueue.main.async {
            self.onlineUsers = [:]
            
            self.serverRUChannelSync = false
            self.serverCRSync = false
        }
    }
    
    func resetState(keepPersonalChannel: Bool = false) {
        DispatchQueue.main.async {
            if !keepPersonalChannel { self.personalChannel = nil }
            
            self.RUChannels = [SChannel]()
            
            self.onlineUsers = [:]
            
            self.CRs = [SChannelRequest]()
            self.CDs = [SChannelDeletion]()
            self.RUs = [:]
            
            self.serverRUChannelSync = false
            self.serverCRSync = false
        }
    }
}
