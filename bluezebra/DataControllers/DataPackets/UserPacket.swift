//
//  UserPacket.swift
//  bluezebra
//
//  Created by Harshel Bahl on 18/04/2023.
//

import Foundation

struct UserPacket: Codable {
    var userID: String = UUID().uuidString
    var username: String
    var avatar: String
    var creationDate: String
}
