//
//  User.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/04/2023.
//

import Foundation
import CoreData

struct SUser {
    let userID: String
    let username: String
    let creationDate: Date
    let avatar: String
    let lastOnline: Date?
}

class User: NSManagedObject {
    @NSManaged var userID: String?
    @NSManaged var username: String?
    @NSManaged var creationDate: Date?
    @NSManaged var avatar: String?
    @NSManaged var lastOnline: Date?
}

extension User: ToSafeObject {
    
    func safeObject() throws -> SUser {
        
        guard let userID = self.userID,
              let username = self.username,
              let creationDate = self.creationDate,
              let avatar = self.avatar else {
            throw PError.safeMapError
        }
        
        return SUser(userID: userID,
                     username: username,
                     creationDate: creationDate,
                     avatar: avatar,
                     lastOnline: self.lastOnline)
    }
}

