//
//  ChannelDeletionPacket.swift
//  bluezebra
//
//  Created by Harshel Bahl on 18/04/2023.
//

import Foundation

struct ChannelDeletionPacket: Codable {
    var deletionID: String = UUID().uuidString
    var channelID: String
    var channelType: String
    var deletionDate: String
    var type: String
}
