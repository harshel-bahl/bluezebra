//
//  RemoteUser.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/04/2023.
//

import Foundation
import CoreData

struct SRemoteUser {
    var userID: String
    var active: Bool
    var username: String
    var avatar: String
    var lastOnline: Date?
    var blocked: Bool
}

class RemoteUser: NSManagedObject {
    @NSManaged var userID: String?
    @NSManaged var active: Bool
    @NSManaged var username: String?
    @NSManaged var avatar: String?
    @NSManaged var lastOnline: Date?
    @NSManaged var blocked: Bool
}

extension RemoteUser: ToSafeObject {
    
    func safeObject() throws -> SRemoteUser {
        guard let userID = self.userID,
              let username = self.username,
              let avatar = self.avatar else {
            throw DataPC.PError.safeMapError
        }
        
        return SRemoteUser(userID: userID,
                           active: self.active,
                           username: username,
                           avatar: avatar,
                           lastOnline: self.lastOnline,
                           blocked: self.blocked)
    }
}
