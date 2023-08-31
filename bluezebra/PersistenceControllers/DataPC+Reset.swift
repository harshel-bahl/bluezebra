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
        try await self.deleteMOs(entity: User.self)
        try await self.deleteMOs(entity: Settings.self)
        try await self.deleteMOs(entity: RemoteUser.self)
        try await self.deleteMOs(entity: Channel.self)
        try await self.deleteMOs(entity: ChannelRequest.self)
        try await self.deleteMOs(entity: ChannelDeletion.self)
        try await self.deleteMOs(entity: Message.self)
        try await self.deleteMOs(entity: Event.self)
    
        // FileSystem
        try await self.clearDir(dir: "")
        
        // Keychain
        try self.deleteAllItems()
    }
}
