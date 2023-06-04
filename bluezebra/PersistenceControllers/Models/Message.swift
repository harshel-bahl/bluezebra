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
    var message: String
    var isSender: Bool
    var sent: String?
    var delivered: String?
    var read: String?
    var remoteDeleted: String?
}

class Message: NSManagedObject {
    @NSManaged var messageID: String?
    @NSManaged var channelID: String?
    @NSManaged var userID: String?
    @NSManaged var type: String?
    @NSManaged var date: Date?
    @NSManaged var message: String?
    @NSManaged var isSender: Bool
    @NSManaged var sent: String?
    @NSManaged var delivered: String?
    @NSManaged var read: String?
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
            throw DataPC.PError.safeMapError
        }
        
        return SMessage(messageID: messageID,
                        channelID: channelID,
                        userID: userID,
                        type: type,
                        date: date,
                        message: message,
                        isSender: self.isSender,
                        sent: self.sent,
                        delivered: self.delivered,
                        read: self.read,
                        remoteDeleted: self.remoteDeleted)
    }
}
