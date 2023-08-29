//
//  UserPacket.swift
//  bluezebra
//
//  Created by Harshel Bahl on 18/04/2023.
//

import Foundation

struct UserPacket: Codable {
    let UID: String
    let username: String
    let password: String
    let publicKey: Data
    let avatar: String
    let creationDate: String
}
