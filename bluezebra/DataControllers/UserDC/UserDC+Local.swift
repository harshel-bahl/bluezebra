//
//  UserDC+Local.swift
//  bluezebra
//
//  Created by Harshel Bahl on 19/04/2023.
//

import Foundation

extension UserDC {
    
    /// Local Create Functions
    ///
    func createUserLocally(userID: String = UUID().uuidString,
                           username: String,
                           pin: String,
                           avatar: String,
                           creationDate: Date = DateU.shared.currDT) async throws -> (SUser, SSettings, SChannel) {
        
        let SUser = try await DataPC.shared.createUser(userID: userID,
                                                       username: username,
                                                       creationDate: creationDate,
                                                       avatar: avatar)
        
        let SSettings = try await DataPC.shared.createSettings(pin: pin)
        
        let SChannel = try await DataPC.shared.createChannel(channelID: "personal",
                                                             userID: userID,
                                                             creationDate: creationDate)
        
        try await DataPC.shared.createChannelDir(channelID: "personal")
        
        return (SUser, SSettings, SChannel)
    }
    
    /// Local Sync Functions
    ///
    func syncUserData() async throws {
        let SMO = try await DataPC.shared.fetchSMO(entity: User.self)
        
        self.syncUser(userData: SMO)
    }
    
    func syncUserSettings() async throws {
        let SMO = try await DataPC.shared.fetchSMO(entity: Settings.self)
        
        self.syncSettings(userSettings: SMO)
    }
    
    /// SMO Sync Functions
    ///
    func syncUser(userData: SUser) {
        DispatchQueue.main.async {
            self.userData = userData
        }
    }
    
    func syncSettings(userSettings: SSettings) {
        DispatchQueue.main.async {
            self.userSettings = userSettings
        }
    }
    
    func offline() {
        DispatchQueue.main.async {
            if self.userOnline != false { self.userOnline = false }
            if self.emittedPendingEvents != false { self.emittedPendingEvents = false }
        }
        
#if DEBUG
            DataU.shared.handleSuccess(function: "UserDC.offline")
#endif
    }
    
    func shutdown() {
        DispatchQueue.main.async {
            if self.loggedIn != false { self.loggedIn = false }
            if self.userOnline != false { self.userOnline = false }
            if self.emittedPendingEvents != false { self.emittedPendingEvents = false }
        }
        
#if DEBUG
            DataU.shared.handleSuccess(function: "UserDC.shutdown")
#endif
    }
    
    func resetState() {
        DispatchQueue.main.async {
            if self.userData != nil { self.userData = nil }
            if self.userSettings != nil { self.userSettings = nil }
            if self.loggedIn != false { self.loggedIn = false }
            if self.userOnline != false { self.userOnline = false }
            if self.emittedPendingEvents != false { self.emittedPendingEvents = false }
            
#if DEBUG
            DataU.shared.handleSuccess(function: "UserDC.resetState")
#endif
        }
    }
    
    func deleteUserLocally() async throws {
        try await DataPC.shared.deletePCData()
        self.resetState()
        ChannelDC.shared.resetState()
        MessageDC.shared.resetState()
    }
}
