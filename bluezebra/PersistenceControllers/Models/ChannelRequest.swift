//
//  ChannelRequest.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/04/2023.
//

import Foundation
import CoreData

struct SChannelRequest {
    var requestID: String
    var UID: String
    var date: Date
    var isSender: Bool
}

class ChannelRequest: NSManagedObject {
    @NSManaged var requestID: String?
    @NSManaged var userID: String?
    @NSManaged var date: Date?
    @NSManaged var isSender: Bool
}

extension ChannelRequest: ToSafeObject {
    
    func safeObject() throws -> SChannelRequest {
        guard let requestID = self.requestID,
              let UID = self.userID,
              let date = self.date else {
            throw PError.safeMapError(err: "ChannelRequest required property(s) nil")
        }
        
        return SChannelRequest(requestID: requestID,
                               UID: UID,
                               date: date,
                               isSender: self.isSender)
    }
}
