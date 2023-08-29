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
                           creationDate: Date = DateU.shared.currDT) async throws -> (SUser, String, Data, SSettings, SChannel) {
        
        let userdata = try await DataPC.shared.createUser(userID: userID,
                                                       username: username,
                                                       creationDate: creationDate,
                                                       avatar: avatar)
        
        let password = SecurityU.shared.generateRandPass(length: 12)
        
        try DataPC.shared.storePassword(account: "userPassword", password: password)
         
        let keys = try SecurityU.shared.generateKeyPair()
        
        guard let privateKey = keys["privateKey"],
              let publicKey = keys["publicKey"] else { throw DCError.nilError(func: "UserDC.createUserLocally") }
        
        try DataPC.shared.storeKey(keyData: privateKey, account: "userPrivateKey", isPublic: false)
        try DataPC.shared.storeKey(keyData: publicKey, account: "userPublicKey", isPublic: true)
        
        let userSettings = try await DataPC.shared.createSettings(pin: pin)
        
        let personalChannel = try await DataPC.shared.createChannel(channelID: "personal",
                                                             userID: userID,
                                                             creationDate: creationDate)
        
        try await DataPC.shared.createChannelDir(channelID: "personal")
        
        return (userdata, password, publicKey, userSettings, personalChannel)
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
    
    /// updateLastOnline
    ///
    func updateLastOnline(datetime: Date = DateU.shared.currDT) async throws {
        
        let SMO = try await DataPC.shared.updateMO(entity: User.self,
                                                   property: ["lastOnline"],
                                                   value: [datetime])
        self.syncUser(userData: SMO)
    }
    
    func offline() {
        DispatchQueue.main.async {
            if self.userOnline != false { self.userOnline = false }
            if self.emittedPendingEvents != false { self.emittedPendingEvents = false }
        }
    }
    
    func shutdown() {
        DispatchQueue.main.async {
            if self.loggedIn != false { self.loggedIn = false }
            if self.userOnline != false { self.userOnline = false }
            if self.emittedPendingEvents != false { self.emittedPendingEvents = false }
        }
    }
    
    func resetState() {
        DispatchQueue.main.async {
            if self.userData != nil { self.userData = nil }
            if self.userSettings != nil { self.userSettings = nil }
            if self.loggedIn != false { self.loggedIn = false }
            if self.userOnline != false { self.userOnline = false }
            if self.emittedPendingEvents != false { self.emittedPendingEvents = false }
        }
    }
    
    func deleteUserLocally() async throws {
        try await DataPC.shared.deletePCData()
        self.resetState()
        ChannelDC.shared.resetState()
        MessageDC.shared.resetState()
    }
}
