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
    func createUserLocally(uID: UUID = UUID(),
                           username: String,
                           pin: String,
                           avatar: String,
                           creationDate: Date = DateU.shared.currDT) async throws -> (SUser, String, Data, SSettings, SChannel) {
        
        let (userdata, userSettings) = try await DataPC.shared.backgroundPerformAsync(saveOnComplete: true,
                                                                                      rollbackOnErr: true) {
            
            let userdataMO = try DataPC.shared.createUser(uID: uID,
                                                          username: username,
                                                          creationDate: creationDate,
                                                          avatar: avatar)
            
            let userSettingsMO = try DataPC.shared.createSettings(user: userdataMO)
            
            let userdata = try userdataMO.safeObject()
            let userSettings = try userSettingsMO.safeObject()
            
            return (userdata, userSettings)
        }
        
        let password = SecurityU.shared.generateRandPass(length: 20)
        
        try DataPC.shared.storePassword(account: "userPassword", password: password)
        
        let keys = try SecurityU.shared.generateKeyPair()
        
        guard let privateKey = keys["privateKey"],
              let publicKey = keys["publicKey"] else { throw DCError.nilError(err: "public or private key is nil") }
        
        try DataPC.shared.storeKey(keyData: privateKey, account: "userPrivateKey", isPublic: false)
        try DataPC.shared.storeKey(keyData: publicKey, account: "userPublicKey", isPublic: true)
        
        let personalChannel = try await DataPC.shared.createChannel(channelID: "personal",
                                                                    uID: uID,
                                                                    creationDate: creationDate)
        
        try await DataPC.shared.createChannelDir(channelID: "personal")
        
        return (userdata, password, publicKey, userSettings, personalChannel)
    }
    
    /// Local Delete Functions
    ///
    func deleteUserLocally() async throws {
        try await DataPC.shared.deletePCData()
        self.resetState()
        ChannelDC.shared.resetState()
        MessageDC.shared.resetState()
    }
    
    /// Local Sync Functions
    ///
    func syncUserdata() async throws {
        let SMO = try await DataPC.shared.fetchSMO(entity: User.self)
        
        self.syncUserdata(userdata: SMO)
    }
    
    func syncUserSettings() async throws {
        let SMO = try await DataPC.shared.fetchSMO(entity: Settings.self)
        
        self.syncSettings(userSettings: SMO)
    }
    
    /// SMO Sync Functions
    ///
    func syncUserdata(userdata: SUser) {
        DispatchQueue.main.async {
            self.userdata = userdata
        }
    }
    
    func syncSettings(userSettings: SSettings) {
        DispatchQueue.main.async {
            self.userSettings = userSettings
        }
    }
    
    func syncUserConnected(result: Bool) {
        DispatchQueue.main.async {
            self.userConnected = result
        }
    }
    
    func syncReceivedPendingEvents(result: Bool) {
        DispatchQueue.main.async {
            self.receivedPendingEvents = result
        }
    }
    
    func updateLastOnline(datetime: Date = DateU.shared.currDT) async throws {
        
        let SMO = try await DataPC.shared.updateMO(entity: User.self,
                                                   property: ["lastOnline"],
                                                   value: [datetime])
        
        self.syncUserdata(userdata: SMO)
    }
    
    func offline() {
        DispatchQueue.main.async {
            if self.userConnected != false { self.userConnected = false }
            if self.receivedPendingEvents != false { self.receivedPendingEvents = false }
        }
    }
    
    func shutdown() {
        DispatchQueue.main.async {
            if self.loggedIn != false { self.loggedIn = false }
            if self.userConnected != false { self.userConnected = false }
            if self.receivedPendingEvents != false { self.receivedPendingEvents = false }
        }
    }
    
    func resetState() {
        DispatchQueue.main.async {
            if self.userdata != nil { self.userdata = nil }
            if self.userSettings != nil { self.userSettings = nil }
            if self.loggedIn != false { self.loggedIn = false }
            if self.userConnected != false { self.userConnected = false }
            if self.receivedPendingEvents != false { self.receivedPendingEvents = false }
        }
    }
}
