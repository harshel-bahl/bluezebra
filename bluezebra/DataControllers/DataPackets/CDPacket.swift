//
//  CDPacket.swift
//  bluezebra
//
//  Created by Harshel Bahl on 18/04/2023.
//

import Foundation

struct CDPacket: Codable {
    var deletionID: String = UUID().uuidString
    var deletionDate: String
    var type: String
    var channelID: String
}
