//
//  DataPC+Reset.swift
//  bluezebra
//
//  Created by Harshel Bahl on 15/04/2023.
//

import Foundation
import CoreData

extension DataPC {
    
    /// DataPC Deletion Functions
    ///
    
    public func deletePCData() async throws {
        
        // Core Data
        try await self.backgroundPerformSync() {
            try self.deleteMOs(entity: User.self)
            try self.deleteMOs(entity: Settings.self)
            try self.deleteMOs(entity: RemoteUser.self)
            try self.deleteMOs(entity: Channel.self)
            try self.deleteMOs(entity: ChannelRequest.self)
            try self.deleteMOs(entity: ChannelDeletion.self)
            try self.deleteMOs(entity: Message.self)
            try self.deleteMOs(entity: Event.self)
        }
    
        // FileSystem
        try await self.clearDir(dir: "")
        
        // Keychain
        try self.deleteAllKeychainItems()
    }
}
