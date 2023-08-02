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
        let SMO = try await DataPC.shared.fetchSMOAsync(entity: User.self)
        
        DispatchQueue.main.async {
            self.userData = SMO
        }
    }
    
    func syncUserSettings() async throws {
        let SMO = try await DataPC.shared.fetchSMOAsync(entity: Settings.self)
        
        DispatchQueue.main.async {
            self.userSettings = SMO
        }
    }
    
    /// SMO Sync Functions
    ///
    func syncUserSMO(userData: SUser) {
        DispatchQueue.main.async {
            self.userData = userData
        }
    }
    
    func syncSettingsSMO(userSettings: SSettings) {
        DispatchQueue.main.async {
            self.userSettings = userSettings
        }
    }
    
    func resetUserData() async throws {
        try await DataPC.shared.resetUserData()
        ChannelDC.shared.resetState()
        MessageDC.shared.resetState()
    }
    
    func hardReset() async throws {
        try await DataPC.shared.hardResetDataPC()
        self.resetState()
        ChannelDC.shared.resetState()
        MessageDC.shared.resetState()
    }
}
