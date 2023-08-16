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
        try await self.fetchDeleteMOs(entity: User.self)
        try await self.fetchDeleteMOs(entity: Settings.self)
        try await self.fetchDeleteMOs(entity: RemoteUser.self)
        try await self.fetchDeleteMOs(entity: Channel.self)
        try await self.fetchDeleteMOs(entity: ChannelRequest.self)
        try await self.fetchDeleteMOs(entity: ChannelDeletion.self)
        try await self.fetchDeleteMOs(entity: Message.self)
        try await self.fetchDeleteMOs(entity: Event.self)
    
        try await self.clearDir(dir: "")
    }
}
