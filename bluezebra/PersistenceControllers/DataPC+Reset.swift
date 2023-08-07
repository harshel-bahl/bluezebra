//
//  DataPC+Reset.swift
//  bluezebra
//
//  Created by Harshel Bahl on 15/04/2023.
//

import Foundation
import CoreData

extension DataPC {
    
    /// Reset DataPC Functions
    ///
    
    public func hardResetDataPC() async throws {
        try await self.fetchDeleteMOsAsync(entity: User.self)
        try await self.fetchDeleteMOsAsync(entity: Settings.self)
        try await self.fetchDeleteMOsAsync(entity: RemoteUser.self)
        try await self.fetchDeleteMOsAsync(entity: Channel.self)
        try await self.fetchDeleteMOsAsync(entity: ChannelRequest.self)
        try await self.fetchDeleteMOsAsync(entity: ChannelDeletion.self)
        try await self.fetchDeleteMOsAsync(entity: Message.self)
        
        print("CLIENT \(DateU.shared.logTS) -- DataPC.hardResetDataPC: SUCCESS")
    }
}
