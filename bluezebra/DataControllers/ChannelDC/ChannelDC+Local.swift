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
        if self.personalChannel==nil { try await self.syncPersonalChannel() }
        if self.channels.isEmpty { try await self.syncChannels() }
        if self.CRs.isEmpty { try await self.syncCRs() }
        if self.CDs.isEmpty { try await self.syncCDs() }
    }
    
    func syncRUs(fetchLimit: Int? = nil) async throws {
        
        let SMOs = try await DataPC.shared.fetchSMOsAsync(entity: RemoteUser.self,
                                                           fetchLimit: fetchLimit)
        
        DispatchQueue.main.async {
            for SMO in SMOs {
                self.RUs[SMO.userID] = SMO
            }
        }
    }
    
    func syncPersonalChannel() async throws {
        let SMO = try await DataPC.shared.fetchSMOAsync(entity: Channel.self,
                                                         predicateProperty: "channelID",
                                                         predicateValue: "personal")
        
        DispatchQueue.main.async {
            self.personalChannel = SMO
        }
    }
    
    func syncChannels(fetchLimit: Int? = nil) async throws {
        
        let predicate = NSPredicate(format: "active == %@ AND channelID != %@",
                                    argumentArray: [true, "personal"])
        
        let SMOs = try await DataPC.shared.fetchSMOsAsync(entity: Channel.self,
                                                           customPredicate: predicate,
                                                           fetchLimit: fetchLimit,
                                                           sortKey: "lastMessageDate")
        let sortedSMOs = self.sortNilDates(channels: SMOs)
        
        DispatchQueue.main.async {
            self.channels = sortedSMOs
        }
    }
    
    func syncCRs(fetchLimit: Int? = nil) async throws {
        
        let SMOs = try await DataPC.shared.fetchSMOsAsync(entity: ChannelRequest.self,
                                                           fetchLimit: fetchLimit,
                                                           sortKey: "date")
        
        DispatchQueue.main.async {
            self.CRs = SMOs
        }
    }
    
    
    func syncCDs(fetchLimit: Int? = nil) async throws {
        
        let SMOs = try await DataPC.shared.fetchSMOsAsync(entity: ChannelDeletion.self,
                                                          fetchLimit: fetchLimit,
                                                          sortKey: "deletionDate")
        
        DispatchQueue.main.async {
            self.CDs = SMOs
        }
    }
    
    /// Date Sorting Functions
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
    
    /// Local Delete Functions
    ///
    func deleteRU(userID: String) {
        DispatchQueue.main.async {
            self.RUs.removeValue(forKey: userID)
        }
    }
    
    func deleteChannel(channelID: String) {
        DispatchQueue.main.async {
            let channelIndex = self.channels.firstIndex(where: { $0.channelID == channelID })
            if let channelIndex = channelIndex {
                self.channels.remove(at: channelIndex)
            }
        }
    }
    
    func deleteCR(channelID: String) {
        DispatchQueue.main.async {
            let CRIndex = self.CRs.firstIndex(where: { $0.channelID == channelID })
            if let CRIndex = CRIndex {
                self.CRs.remove(at: CRIndex)
            }
        }
    }
    
    func deleteCD(deletionID: String) {
        DispatchQueue.main.async {
            let CDIndex = self.CDs.firstIndex(where: { $0.deletionID == deletionID })
            if let CDIndex = CDIndex {
                self.CDs.remove(at: CDIndex)
            }
        }
    }
    
    /// Local Fetch Functions
    ///
    func fetchRULocally(userID: String) async throws -> SRemoteUser {
        
        let SMO = try await DataPC.shared.fetchSMOAsync(entity: RemoteUser.self,
                                                        predicateProperty: "userID",
                                                        predicateValue: userID)
        return SMO
    }
    
    func fetchChannelLocally(channelID: String) async throws -> SChannel {
        
        let SMO = try await DataPC.shared.fetchSMOAsync(entity: Channel.self,
                                                        predicateProperty: "channelID",
                                                        predicateValue: channelID)
        return SMO
    }
    
    func fetchCRLocally(channelID: String) async throws -> SChannelRequest {
        
        let SMO = try await DataPC.shared.fetchSMOAsync(entity: ChannelRequest.self,
                                                        predicateProperty: "channelID",
                                                        predicateValue: channelID)
        return SMO
    }
    
    func fetchCDLocally(deletionID: String) async throws -> SChannelDeletion {
        
        let SMO = try await DataPC.shared.fetchSMOAsync(entity: ChannelDeletion.self,
                                                        predicateProperty: "deletionID",
                                                        predicateValue: deletionID)
        return SMO
    }
    
    
    
    //    func checkRUInTeams(userID: String) async throws -> Bool {
    //
    //        let predicate = NSPredicate(format: "userIDs CONTAINS %@", userID)
    //
    //        let SMOs = try await DataPC.shared.fetchSMOsAsync(entity: Team.self,
    //                                                          customPredicate: predicate)
    //
    //        if SMOs.isEmpty {
    //            return true
    //        } else {
    //            return false
    //        }
    //    }
}
