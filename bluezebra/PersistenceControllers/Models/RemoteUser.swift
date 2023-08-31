//
//  RemoteUser.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/04/2023.
//

import Foundation
import CoreData

struct SRemoteUser {
    var UID: String
    var username: String
    var avatar: String
    var creationDate: Date
    var lastOnline: Date?
    var blocked: Bool
}

class RemoteUser: NSManagedObject {
    @NSManaged var userID: String?
    @NSManaged var username: String?
    @NSManaged var avatar: String?
    @NSManaged var creationDate: Date?
    @NSManaged var lastOnline: Date?
    @NSManaged var blocked: Bool
}

extension RemoteUser: ToSafeObject {
    
    func safeObject() throws -> SRemoteUser {
        guard let UID = self.userID,
              let username = self.username,
              let avatar = self.avatar,
              let creationDate = self.creationDate else {
            throw PError.safeMapError(err: "RemoteUser required property(s) nil")
        }
        
        return SRemoteUser(UID: UID,
                           username: username,
                           avatar: avatar,
                           creationDate: creationDate,
                           lastOnline: self.lastOnline,
                           blocked: self.blocked)
    }
}
