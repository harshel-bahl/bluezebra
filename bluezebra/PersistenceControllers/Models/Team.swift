//
//  Team.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/04/2023.
//

import Foundation
import CoreData

struct STeam {
    var teamID: String
    var active: Bool
    var userIDs: String
    var nUsers: Int
    var leads: String
    var name: String
    var icon: String
    var creationUserID: String
    var creationDate: Date
    var teamDescription: String?
}

class Team: NSManagedObject {
    @NSManaged var teamID: String?
    @NSManaged var active: Bool
    @NSManaged var userIDs: String?
    @NSManaged var nUsers: Int
    @NSManaged var leads: String?
    @NSManaged var name: String?
    @NSManaged var icon: String?
    @NSManaged var creationUserID: String?
    @NSManaged var creationDate: Date?
    @NSManaged var teamDescription: String?
}

extension Team: ToSafeObject {
    
    func safeObject() throws -> STeam {
        guard let teamID = self.teamID,
              let userIDs = self.userIDs,
              let leads = self.leads,
              let name = self.name,
              let icon = self.icon,
              let creationUserID = self.creationUserID,
              let creationDate = self.creationDate else {
            throw DataPC.PError.safeMapError
        }
        
        return STeam(teamID: teamID,
                     active: self.active,
                     userIDs: userIDs,
                     nUsers: self.nUsers,
                     leads: leads,
                     name: name,
                     icon: icon,
                     creationUserID: creationUserID,
                     creationDate: creationDate,
                     teamDescription: self.teamDescription)
    }
}
