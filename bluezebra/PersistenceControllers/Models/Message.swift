//
//  Message.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/04/2023.
//

import Foundation
import CoreData

struct SMessage {
    var messageID: String = UUID().uuidString
    var channelID: String
    var userID: String
    var type: String
    var date: Date
    var isSender: Bool
    var message: String
    var resourceIDs: String?
    var sent: String?
    var delivered: String?
    var read: String?
    var localDeleted: Bool
    var remoteDeleted: String?
}

class Message: NSManagedObject {
    @NSManaged var messageID: String?
    @NSManaged var channelID: String?
    @NSManaged var userID: String?
    @NSManaged var type: String?
    @NSManaged var date: Date?
    @NSManaged var isSender: Bool
    @NSManaged var message: String?
    @NSManaged var resourceIDs: String?
    @NSManaged var sent: String?
    @NSManaged var delivered: String?
    @NSManaged var read: String?
    @NSManaged var localDeleted: Bool
    @NSManaged var remoteDeleted: String?
}

extension Message: ToSafeObject {
    
    func safeObject() throws -> SMessage {
        guard let messageID = self.messageID,
              let channelID = self.channelID,
              let userID = self.userID,
              let type = self.type,
              let date = self.date,
              let message = self.message else {
            throw PError.safeMapError
        }
        
        return SMessage(messageID: messageID,
                        channelID: channelID,
                        userID: userID,
                        type: type,
                        date: date,
                        isSender: self.isSender,
                        message: message,
                        resourceIDs: self.resourceIDs,
                        sent: self.sent,
                        delivered: self.delivered,
                        read: self.read,
                        localDeleted: self.localDeleted,
                        remoteDeleted: self.remoteDeleted)
    }
}
