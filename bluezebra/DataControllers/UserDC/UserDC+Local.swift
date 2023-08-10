//
//  UserDC+Local.swift
//  bluezebra
//
//  Created by Harshel Bahl on 19/04/2023.
//

import Foundation

extension UserDC {
    
    /// Local Sync Functions
    ///
    func syncUserData() async throws {
        let SMO = try await DataPC.shared.fetchSMO(entity: User.self)
        
        DispatchQueue.main.async {
            self.userData = SMO
        }
    }
    
    func syncUserSettings() async throws {
        let SMO = try await DataPC.shared.fetchSMO(entity: Settings.self)
        
        DispatchQueue.main.async {
            self.userSettings = SMO
        }
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
    
    /// Reset Functions
    func hardReset() async throws {
        try await DataPC.shared.hardResetDataPC()
        self.resetState()
        ChannelDC.shared.resetState()
        MessageDC.shared.resetState()
    }
    
    func resetState() {
        DispatchQueue.main.async {
            if self.userData != nil { self.userData = nil }
            if self.userSettings != nil { self.userSettings = nil }
            if self.loggedIn != false { self.loggedIn = false }
            if self.userOnline != false { self.userOnline = false }
            
            #if DEBUG
            print("SUCCESS \(DateU.shared.logTS) -- UserDC.resetState")
            #endif
        }
    }
}
