//
//  RemoteUserPacket.swift
//  bluezebra
//
//  Created by Harshel Bahl on 18/04/2023.
//

import Foundation

struct RemoteUserPacket: Codable {
    var userID: String
    var username: String
    var avatar: String
    var lastOnline: String?
}
