//
//  MessagePacket.swift
//  bluezebra
//
//  Created by Harshel Bahl on 22/04/2023.
//

import Foundation

struct MessagePacket: Codable {
    var messageID: String = UUID().uuidString
    var channelID: String
    var userID: String
    var type: String
    var date: String
    var message: String
}
