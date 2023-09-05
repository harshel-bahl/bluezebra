//
//  ChannelRequest.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/04/2023.
//

import Foundation
import CoreData

struct SChannelRequest {
    var requestID: UUID
    var uID: UUID
    var date: Date
    var isSender: Bool
}

class ChannelRequest: NSManagedObject {
    @NSManaged var requestID: UUID?
    @NSManaged var uID: UUID
    @NSManaged var date: Date?
    @NSManaged var isSender: Bool
}

extension ChannelRequest: ToSafeObject {
    
    func safeObject() throws -> SChannelRequest {
        guard let requestID = self.requestID,
              let uID = self.uID,
              let date = self.date else {
            throw PError.safeMapError(err: "ChannelRequest required property(s) nil")
        }
        
        return SChannelRequest(requestID: requestID,
                               uID: uID,
                               date: date,
                               isSender: self.isSender)
    }
}
