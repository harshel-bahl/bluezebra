//
//  CRPacket.swift
//  bluezebra
//
//  Created by Harshel Bahl on 18/04/2023.
//

import Foundation

struct CRPacket: Codable {
    var requestID: String
    var date: String
    var RU: RUPacket
}
