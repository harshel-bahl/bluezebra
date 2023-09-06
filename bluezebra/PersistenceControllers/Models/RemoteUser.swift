//
//  RemoteUser.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/04/2023.
//

import Foundation
import CoreData

struct SRemoteUser {
    var uID: UUID
    var username: String
    var avatar: String
    var creationDate: Date
    var lastOnline: Date?
    var blocked: Bool
}

class RemoteUser: NSManagedObject {
    @NSManaged var uID: UUID
    @NSManaged var username: String
    @NSManaged var avatar: String
    @NSManaged var creationDate: Date
    @NSManaged var lastOnline: Date?
    @NSManaged var blocked: Bool
    
    @NSManaged var channel: Channel?
    @NSManaged var channelRequest: ChannelRequest?
    @NSManaged var messages: Set<Message>?
}

extension RemoteUser: ToSafeObject {
    
    func safeObject() throws -> SRemoteUser {
        return SRemoteUser(uID: self.uID,
                           username: self.username,
                           avatar: self.avatar,
                           creationDate: self.creationDate,
                           lastOnline: self.lastOnline,
                           blocked: self.blocked)
    }
}
