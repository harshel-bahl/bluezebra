//
//  CDPacket.swift
//  bluezebra
//
//  Created by Harshel Bahl on 18/04/2023.
//

import Foundation

struct CDP: Codable {
    let channelID: UUID
    let deletionDate: Date
    let deletionType: String
}
