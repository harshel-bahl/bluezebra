//
//  MessagePacket.swift
//  bluezebra
//
//  Created by Harshel Bahl on 22/04/2023.
//

import Foundation

struct MessageP: Codable {
    var messageID: String 
    var channelID: String
    var uID: String
    var date: String
    var message: String
}
