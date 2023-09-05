//
//  User.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/04/2023.
//

import Foundation
import CoreData

struct SUser {
    let uID: UUID
    let username: String
    let creationDate: Date
    let avatar: String
    let lastOnline: Date?
}

class User: NSManagedObject {
    @NSManaged var uID: UUID?
    @NSManaged var username: String?
    @NSManaged var creationDate: Date?
    @NSManaged var avatar: String?
    @NSManaged var lastOnline: Date?
    
    @NSManaged var settings: Settings?
}

extension User: ToSafeObject {
    
    func safeObject() throws -> SUser {
        
        guard let uID = self.uID,
              let username = self.username,
              let creationDate = self.creationDate,
              let avatar = self.avatar else {
            throw PError.safeMapError(err: "User required property(s) nil")
        }
        
        return SUser(uID: uID,
                     username: username,
                     creationDate: creationDate,
                     avatar: avatar,
                     lastOnline: self.lastOnline)
    }
}

