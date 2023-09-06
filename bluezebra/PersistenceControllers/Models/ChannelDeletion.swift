//
//  ChannelDeletion.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/04/2023.
//

import Foundation
import CoreData

struct SChannelDeletion {
    var deletionID: UUID
    var channelType: String
    var deletionDate: Date
    var type: String
    var name: String
    var icon: String
    var nUsers: Int16
    var toDeleteUIDs: String
    var isOrigin: Bool
    var remoteDeletedDate: Date?
}

class ChannelDeletion: NSManagedObject {
    @NSManaged var deletionID: UUID
    @NSManaged var channelType: String
    @NSManaged var deletionDate: Date
    @NSManaged var type: String
    @NSManaged var name: String
    @NSManaged var icon: String
    @NSManaged var nUsers: Int16
    @NSManaged var toDeleteUIDs: String
    @NSManaged var isOrigin: Bool
    @NSManaged var remoteDeletedDate: Date?
}

extension ChannelDeletion: ToSafeObject {
    
    func safeObject() throws -> SChannelDeletion {
        return SChannelDeletion(deletionID: self.deletionID,
                                channelType: self.channelType,
                                deletionDate: self.deletionDate,
                                type: self.type,
                                name: self.name,
                                icon: self.icon,
                                nUsers: self.nUsers,
                                toDeleteUIDs: self.toDeleteUIDs,
                                isOrigin: self.isOrigin,
                                remoteDeletedDate: self.remoteDeletedDate)
    }
}
