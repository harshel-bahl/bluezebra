//
//  Channel.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/04/2023.
//

import Foundation
import CoreData

struct SChannel {
    var channelID: String
    var active: Bool
    var userID: String
    var creationDate: Date
    var lastMessageDate: Date?
}

class Channel: NSManagedObject {
    @NSManaged var channelID: String?
    @NSManaged var active: Bool
    @NSManaged var userID: String?
    @NSManaged var creationDate: Date?
    @NSManaged var lastMessageDate: Date?
}

extension Channel: ToSafeObject {
    
    func safeObject() throws -> SChannel {
        guard let channelID = self.channelID,
              let userID = self.userID,
              let creationDate =  self.creationDate else {
            throw PError.safeMapError
        }
        
        return SChannel(channelID: channelID,
                        active: self.active,
                        userID: userID,
                        creationDate: creationDate,
                        lastMessageDate: self.lastMessageDate)
    }
}
