//
//  ChannelPacket.swift
//  bluezebra
//
//  Created by Harshel Bahl on 02/05/2023.
//

import Foundation

struct ChannelPacket: Codable {
    var channelID: String = UUID().uuidString
    var channelType: String
    var userID: String?
    var teamID: String?
    var creationUserID: String
}
