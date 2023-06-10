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
    var channelType: String
    var userID: String?
    var teamID: String?
    var creationUserID: String
    var creationDate: Date
    var lastMessageDate: Date?
}

class Channel: NSManagedObject {
    @NSManaged var channelID: String?
    @NSManaged var active: Bool
    @NSManaged var channelType: String?
    @NSManaged var userID: String?
    @NSManaged var teamID: String?
    @NSManaged var creationUserID: String?
    @NSManaged var creationDate: Date?
    @NSManaged var lastMessageDate: Date?
}

extension Channel: ToSafeObject {
    
    func safeObject() throws -> SChannel {
        guard let channelID = self.channelID,
              let channelType = self.channelType,
              let creationUserID = self.creationUserID,
              let creationDate =  self.creationDate else {
            throw PError.safeMapError
        }
        
        return SChannel(channelID: channelID,
                        active: self.active,
                        channelType: channelType,
                        userID: self.userID,
                        teamID: self.teamID,
                        creationUserID: creationUserID,
                        creationDate: creationDate,
                        lastMessageDate: self.lastMessageDate)
    }
}
