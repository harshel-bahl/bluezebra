//
//  Channel.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/04/2023.
//

import Foundation
import CoreData

struct SChannel {
    var channelID: UUID
    var uID: String
    var creationDate: Date
    var lastMessageDate: Date?
}

class Channel: NSManagedObject {
    @NSManaged var channelID: UUID?
    @NSManaged var uID: String?
    @NSManaged var creationDate: Date?
    @NSManaged var lastMessageDate: Date?
    
    @NSManaged var RU: RemoteUser?
    @NSManaged var messages: Set<Message>?
}

extension Channel: ToSafeObject {
    
    func safeObject() throws -> SChannel {
        guard let channelID = self.channelID,
              let uID = self.uID,
              let creationDate =  self.creationDate else {
            throw PError.safeMapError(err: "Channel required property(s) nil")
        }
        
        return SChannel(channelID: channelID,
                        uID: uID,
                        creationDate: creationDate,
                        lastMessageDate: self.lastMessageDate)
    }
}
