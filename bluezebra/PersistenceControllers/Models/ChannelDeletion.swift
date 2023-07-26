//
//  ChannelDeletion.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/04/2023.
//

import Foundation
import CoreData

struct SChannelDeletion {
    var deletionID: String
    var channelType: String
    var deletionDate: Date
    var type: String
    var name: String
    var icon: String
    var nUsers: Int16
    var toDeleteUserIDs: String?
    var isOrigin: Bool
    var remoteDeletedDate: Date?
}

class ChannelDeletion: NSManagedObject {
    @NSManaged var deletionID: String?
    @NSManaged var channelType: String?
    @NSManaged var deletionDate: Date?
    @NSManaged var type: String?
    @NSManaged var name: String?
    @NSManaged var icon: String?
    @NSManaged var nUsers: Int16
    @NSManaged var toDeleteUserIDs: String?
    @NSManaged var isOrigin: Bool
    @NSManaged var remoteDeletedDate: Date?
}

extension ChannelDeletion: ToSafeObject {
    
    func safeObject() throws -> SChannelDeletion {
        guard let deletionID = self.deletionID,
              let channelType = self.channelType,
              let deletionDate = self.deletionDate,
              let type = self.type,
              let name = self.name,
              let icon = self.icon else {
            throw PError.safeMapError
        }
        
        return SChannelDeletion(deletionID: deletionID,
                                channelType: channelType,
                                deletionDate: deletionDate,
                                type: type,
                                name: name,
                                icon: icon,
                                nUsers: self.nUsers,
                                toDeleteUserIDs: self.toDeleteUserIDs,
                                isOrigin: self.isOrigin,
                                remoteDeletedDate: self.remoteDeletedDate)
    }
}
