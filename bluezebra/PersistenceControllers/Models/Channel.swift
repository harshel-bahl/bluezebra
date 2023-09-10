//
//  Channel.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/04/2023.
//

import Foundation
import CoreData

struct SChannel {
    let channelID: UUID
    let uID: UUID
    let channelType: String
    let creationDate: Date
    let lastMessageDate: Date?
}

class Channel: NSManagedObject {
    @NSManaged var channelID: UUID
    @NSManaged var uID: UUID
    @NSManaged var channelType: String
    @NSManaged var creationDate: Date
    @NSManaged var lastMessageDate: Date?
    
    @NSManaged var remoteUser: RemoteUser?
    @NSManaged var messages: Set<Message>?
}

extension Channel: ToSafeObject {
    
    func safeObject() throws -> SChannel {
        return SChannel(channelID: self.channelID,
                        uID: self.uID,
                        channelType: self.channelType,
                        creationDate: self.creationDate,
                        lastMessageDate: self.lastMessageDate)
    }
}
