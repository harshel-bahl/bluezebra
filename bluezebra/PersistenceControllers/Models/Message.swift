//
//  Message.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/04/2023.
//

import Foundation
import CoreData

struct SMessage: Equatable {
    var messageID: UUID
    var channelID: UUID
    var uID: UUID
    var date: Date
    var isSender: Bool
    var message: String?
    var imageIDs: String?
    var fileIDs: String?
    var sent: String?
    var delivered: String?
    var read: String?
    var localDeleted: Bool
    var remoteDeleted: String?
}

class Message: NSManagedObject {
    @NSManaged var messageID: UUID
    @NSManaged var channelID: UUID
    @NSManaged var uID: UUID
    @NSManaged var date: Date
    @NSManaged var isSender: Bool
    @NSManaged var message: String?
    @NSManaged var imageIDs: String?
    @NSManaged var fileIDs: String?
    @NSManaged var sent: String?
    @NSManaged var delivered: String?
    @NSManaged var read: String?
    @NSManaged var localDeleted: Bool
    @NSManaged var remoteDeleted: String?
    
    @NSManaged var channel: Channel
    @NSManaged var remoteUser: RemoteUser
}

extension Message: ToSafeObject {
    
    func safeObject() throws -> SMessage {
        return SMessage(messageID: self.messageID,
                        channelID: self.channelID,
                        uID: self.uID,
                        date: self.date,
                        isSender: self.isSender,
                        message: self.message,
                        imageIDs: self.imageIDs,
                        fileIDs: self.fileIDs,
                        sent: self.sent,
                        delivered: self.delivered,
                        read: self.read,
                        localDeleted: self.localDeleted,
                        remoteDeleted: self.remoteDeleted)
    }
}
