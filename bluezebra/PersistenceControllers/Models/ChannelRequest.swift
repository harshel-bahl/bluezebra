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
    @NSManaged var requestID: UUID
    @NSManaged var uID: UUID
    @NSManaged var date: Date
    @NSManaged var isSender: Bool
    
    @NSManaged var remoteUser: RemoteUser
}

extension ChannelRequest: ToSafeObject {
    
    func safeObject() throws -> SChannelRequest {
        return SChannelRequest(requestID: self.requestID,
                               uID: self.uID,
                               date: self.date,
                               isSender: self.isSender)
    }
}
