//
//  ChannelDC+Local.swift
//  bluezebra
//
//  Created by Harshel Bahl on 19/04/2023.
//

import Foundation

extension ChannelDC {
    
    /// Local Read/Write Functions
    ///
    func fetchAllData() async {
        await self.fetchRemoteUsers()
        await self.fetchTeams()
        await self.fetchPersonalChannel()
        await self.fetchUserChannels()
        await self.fetchTeamChannels()
        await self.fetchChannelRequests()
        await self.fetchChannelDeletions()
    }
    
    func fetchRemoteUsers(fetchLimit: Int? = nil,
                          completion: (([SRemoteUser])->())? = nil) async {
        
        let SMOs = try? await DataPC.shared.fetchSMOsAsync(entity: RemoteUser.self,
                                                           predicateProperty: "active",
                                                           predicateValue: true,
                                                           fetchLimit: fetchLimit)
        
        guard let SMOs = SMOs else { return }
        
        DispatchQueue.main.async {
            for SMO in SMOs {
                self.remoteUsers[SMO.userID] = SMO
            }
            
            if let completion = completion { completion(SMOs) }
        }
    }
    
    
    func fetchTeams(fetchLimit: Int? = nil,
                    completion: (([STeam])->())? = nil) async {
        
        let SMOs = try? await DataPC.shared.fetchSMOsAsync(entity: Team.self,
                                                           predicateProperty: "active",
                                                           predicateValue: true,
                                                           fetchLimit: fetchLimit)
        guard let SMOs = SMOs else { return }
        
        DispatchQueue.main.async {
            for SMO in SMOs {
                self.teams[SMO.teamID] = SMO
            }
            
            if let completion = completion { completion(SMOs) }
        }
    }
    
    func fetchPersonalChannel(completion: ((SChannel)->())? = nil) async {
        let SMO = try? await DataPC.shared.fetchSMOAsync(entity: Channel.self,
                                                         predicateProperty: "channelType",
                                                         predicateValue: "personal")
        
        guard let SMO = SMO else { return }
        
        DispatchQueue.main.async {
            self.personalChannel = SMO
            
            if let completion = completion { completion(SMO) }
        }
    }
    
    func fetchUserChannels(fetchLimit: Int? = nil,
                           completion: (([SChannel])->())? = nil) async {
        let predicate = NSPredicate(format: "active == %@ AND channelType == %@",
                                    argumentArray: [true, "User"])
        
        let SMOs = try? await DataPC.shared.fetchSMOsAsync(entity: Channel.self,
                                                           customPredicate: predicate,
                                                           fetchLimit: fetchLimit,
                                                           sortKey: "lastMessageDate")
        guard let SMOs = SMOs else { return }
        
        DispatchQueue.main.async {
            self.userChannels = SMOs
            
            if let completion = completion { completion(SMOs) }
        }
    }
    
    
    func fetchTeamChannels(fetchLimit: Int? = nil,
                           completion: (([SChannel])->())? = nil) async {
        let predicate = NSPredicate(format: "active == %@ AND channelType == %@",
                                    argumentArray: [true, "Team"])
        
        let SMOs = try? await DataPC.shared.fetchSMOsAsync(entity: Channel.self,
                                                           customPredicate: predicate,
                                                           fetchLimit: fetchLimit,
                                                           sortKey: "lastMessageDate")
        guard let SMOs = SMOs else { return }
        
        DispatchQueue.main.async {
            self.teamChannels = SMOs
            
            if let completion = completion { completion(SMOs) }
        }
    }
    
    
    func fetchChannelRequests(fetchLimit: Int? = nil,
                              completion: (([SChannelRequest])->())? = nil) async {
        
        let SMOs = try? await DataPC.shared.fetchSMOsAsync(entity: ChannelRequest.self,
                                                           fetchLimit: fetchLimit,
                                                           sortKey: "date")
        guard let SMOs = SMOs else { return }
        
        DispatchQueue.main.async {
            self.channelRequests = SMOs
            
            if let completion = completion { completion(SMOs) }
        }
    }
    
    
    func fetchChannelDeletions(fetchLimit: Int? = nil,
                               completion: (([SChannelDeletion])->())? = nil) async {
        
        let SMOs = try? await DataPC.shared.fetchSMOsAsync(entity: ChannelDeletion.self,
                                                           fetchLimit: fetchLimit,
                                                           sortKey: "deletionDate")
        
        guard let SMOs = SMOs else { return }
        
        DispatchQueue.main.async {
            self.channelDeletions = SMOs
            
            if let completion = completion { completion(SMOs) }
        }
    }
    
    func checkRUInTeams(userID: String) async throws -> Bool {
        
        let predicate = NSPredicate(format: "userIDs CONTAINS %@", userID)
        
        let SMOs = try await DataPC.shared.fetchSMOsAsync(entity: Team.self,
                                                          customPredicate: predicate)
        
        if SMOs.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    func fetchRemoteUserLocally(userID: String) async throws -> SRemoteUser {
        
        let SMO = try await DataPC.shared.fetchSMOAsync(entity: RemoteUser.self,
                                                        predicateProperty: "userID",
                                                        predicateValue: userID)
        return SMO
    }
    
    func fetchTeamLocally(teamID: String) async throws -> STeam {
        
        let SMO = try await DataPC.shared.fetchSMOAsync(entity: Team.self,
                                                        predicateProperty: "teamID",
                                                        predicateValue: teamID)
        return SMO
    }
}
