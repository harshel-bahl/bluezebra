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
    var date: Date
    var isSender: Bool
}

class ChannelRequest: NSManagedObject {
    @NSManaged var channelID: String?
    @NSManaged var userID: String?
    @NSManaged var date: Date?
    @NSManaged var isSender: Bool
}

extension ChannelRequest: ToSafeObject {
    
    func safeObject() throws -> SChannelRequest {
        guard let channelID = self.channelID,
              let date = self.date else {
            throw PError.safeMapError
        }
        
        return SChannelRequest(channelID: channelID,
                               userID: self.userID,
                               date: date,
                               isSender: self.isSender)
    }
}
