//
//  UserDC+Local.swift
//  bluezebra
//
//  Created by Harshel Bahl on 19/04/2023.
//

import Foundation

extension UserDC {
    
    /// Local Read/Write Functions
    ///
    
    func syncUserData() async throws {
        let sMO = try await DataPC.shared.fetchSMOAsync(entity: User.self)
        
        DispatchQueue.main.async {
            self.userData = sMO
        }
    }
    
    func syncUserSettings() async throws {
        let sMO = try await DataPC.shared.fetchSMOAsync(entity: Settings.self)
        
        DispatchQueue.main.async {
            self.userSettings = sMO
        }
    }
    
    func resetUserData() async throws {
        do {
            try await DataPC.shared.resetUserData()
            ChannelDC.shared.resetState()
            MessageDC.shared.resetState()
            print("CLIENT \(DateU.shared.logTS) -- userDC.resetUserData: SUCCESS")
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- userDC.resetUserData: FAILED")
            throw DCError.failed
        }
    }
    
    func hardReset() async throws {
        do {
            try await DataPC.shared.hardResetDataPC()
            self.resetState()
            ChannelDC.shared.resetState()
            MessageDC.shared.resetState()
            print("CLIENT \(DateU.shared.logTS) -- userDC.hardReset: SUCCESS")
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- userDC.hardReset: FAILED")
            throw DCError.failed
        }
    }
}
