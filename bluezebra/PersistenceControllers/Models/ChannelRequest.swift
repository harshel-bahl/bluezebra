//
//  ChannelRequest.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/04/2023.
//

import Foundation
import CoreData

struct SChannelRequest {
    var channelID: String
    var userID: String?
    var teamID: String?
    var date: Date
    var isSender: Bool
    var requestingUserID: String?
}

class ChannelRequest: NSManagedObject {
    @NSManaged var channelID: String?
    @NSManaged var userID: String?
    @NSManaged var teamID: String?
    @NSManaged var date: Date?
    @NSManaged var isSender: Bool
    @NSManaged var requestingUserID: String?
}

extension ChannelRequest: ToSafeObject {
    
    func safeObject() throws -> SChannelRequest {
        guard let channelID = self.channelID,
              let date = self.date else {
            throw DataPC.PError.safeMapError
        }
        
        return SChannelRequest(channelID: channelID,
                               userID: self.userID,
                               teamID: self.teamID,
                               date: date,
                               isSender: self.isSender,
                               requestingUserID: self.requestingUserID)
    }
}
