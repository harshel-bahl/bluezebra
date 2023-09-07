//
//  RUPacket.swift
//  bluezebra
//
//  Created by Harshel Bahl on 20/06/2023.
//

import Foundation

struct RUPacket: Codable {
    var uID: String
    var username: String
    var avatar: String
    var creationDate: String
    var lastOnline: String?
}
