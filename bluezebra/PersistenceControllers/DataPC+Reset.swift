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
        try await self.fetchDeleteMOs(entity: User.self, showLogs: true)
        try await self.fetchDeleteMOs(entity: Settings.self, showLogs: true)
        try await self.fetchDeleteMOs(entity: RemoteUser.self, showLogs: true)
        try await self.fetchDeleteMOs(entity: Channel.self, showLogs: true)
        try await self.fetchDeleteMOs(entity: ChannelRequest.self, showLogs: true)
        try await self.fetchDeleteMOs(entity: ChannelDeletion.self, showLogs: true)
        try await self.fetchDeleteMOs(entity: Message.self, showLogs: true)
        try await self.fetchDeleteMOs(entity: Event.self, showLogs: true)
        
        try await self.clearDir(dir: "")
        
#if DEBUG
        DataU.shared.handleSuccess(function: "DataPC.deletePCData")
#endif
    }
}
