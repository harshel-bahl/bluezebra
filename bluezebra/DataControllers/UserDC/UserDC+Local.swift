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
                           creationDate: Date = DateU.shared.currDT) async throws -> (SUser, SSettings, SChannel, String, Data) {
        
        let (userdata, userSettings, personalChannel) = try await DataPC.shared.backgroundPerformSync(saveOnComplete: true,
                                                                                      rollbackOnErr: true) {
            
            let userdataMO = try DataPC.shared.createUser(uID: uID,
                                                          username: username,
                                                          creationDate: creationDate,
                                                          avatar: avatar)
            
            let userSettingsMO = try DataPC.shared.createSettings(user: userdataMO)
            
            let personalChannelMO = try DataPC.shared.createChannel(channelID: UUID(),
                                                                    uID: uID,
                                                                    channelType: "personal",
                                                                    creationDate: creationDate)
            
            let userdata = try userdataMO.safeObject()
            let userSettings = try userSettingsMO.safeObject()
            let personalChannel = try personalChannelMO.safeObject()
            
            return (userdata, userSettings, personalChannel)
        }
        
        let password = SecurityU.shared.generateRandPass(length: 20)
        
        try DataPC.shared.storePassword(account: "authPassword", password: password)
        
        try DataPC.shared.storePassword(account: "userPin", password: pin)
        
        let keys = try SecurityU.shared.generateKeyPair()
        
        guard let privateKey = keys["privateKey"],
              let publicKey = keys["publicKey"] else { throw DCError.nilError(err: "public or private key is nil") }
        
        try DataPC.shared.storeKey(keyData: privateKey, account: "userPrivateKey", isPublic: false)
        try DataPC.shared.storeKey(keyData: publicKey, account: "userPublicKey", isPublic: true)
        
        try await DataPC.shared.createChannelDir(channelID: "personal")
        
        return (userdata, userSettings, personalChannel, password, publicKey)
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
    
    func syncLoggedIn(result: Bool) {
        DispatchQueue.main.async {
            self.loggedIn = result
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
    
    /// Shutdown functions
    ///
    func updateLastOnline(datetime: Date = DateU.shared.currDT) async throws {
        
        let SMO = try await DataPC.shared.backgroundPerformSync() {
            
            let MO = try DataPC.shared.updateMO(entity: User.self,
                                                property: ["lastOnline"],
                                                value: [datetime])
            
            return try MO.safeObject()
        }
        
        self.syncUserdata(userdata: SMO)
    }
    
    func offline() {
        DispatchQueue.main.async {
            self.userConnected = false
            self.receivedPendingEvents = false
        }
    }
    
    func shutdown() {
        DispatchQueue.main.async {
            self.loggedIn = false
            self.userConnected = false
            self.receivedPendingEvents = false
        }
    }
    
    func resetState() {
        DispatchQueue.main.async {
            self.userdata = nil
          self.userSettings = nil
            self.loggedIn = false
            self.userConnected = false
            self.receivedPendingEvents = false
        }
    }
}
