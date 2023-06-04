//
//  TeamPacket.swift
//  bluezebra
//
//  Created by Harshel Bahl on 02/05/2023.
//

import Foundation

struct TeamPacket: Codable {
    var teamID: String = UUID().uuidString
    var userIDs: String
    var nUsers: Int
    var leads: String
    var name: String
    var icon: String
    var creationUserID: String
    var creationDate: Date
    var teamDescription: String?
}
