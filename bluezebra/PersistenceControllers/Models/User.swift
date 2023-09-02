//
//  User.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/04/2023.
//

import Foundation
import CoreData

struct SUser {
    let uID: String
    let username: String
    let creationDate: Date
    let avatar: String
    let lastOnline: Date?
}

class User: NSManagedObject {
    @NSManaged var uid: String?
    @NSManaged var username: String?
    @NSManaged var creationDate: Date?
    @NSManaged var avatar: String?
    @NSManaged var lastOnline: Date?
}

extension User: ToSafeObject {
    
    func safeObject() throws -> SUser {
        
        guard let UID = self.uid,
              let username = self.username,
              let creationDate = self.creationDate,
              let avatar = self.avatar else {
            throw PError.safeMapError(err: "User required property(s) nil")
        }
        
        return SUser(UID: UID,
                     username: username,
                     creationDate: creationDate,
                     avatar: avatar,
                     lastOnline: self.lastOnline)
    }
}

