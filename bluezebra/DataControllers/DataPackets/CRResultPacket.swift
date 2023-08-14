//
//  CRResult.swift
//  bluezebra
//
//  Created by Harshel Bahl on 11/08/2023.
//

import Foundation

struct CRResultPacket: Codable {
    let requestID: String
    let result: Bool
    let channelID: String
    let creationDate: String
}
