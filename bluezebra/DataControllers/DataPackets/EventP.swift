//
//  EventBatchP.swift
//  bluezebra
//
//  Created by Harshel Bahl on 9/13/23.
//

import Foundation

struct EventP: Codable {

    let eventID: String?
    let eventName: String
    var packet: Any?

    init(eventID: String,
         eventName: String,
         packet: Any? = nil) {
        self.eventID = eventID
        self.eventName = eventName
        self.packet = packet
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.eventID = try container.decodeIfPresent(String.self, forKey: .eventID)
        self.eventName = try container.decode(String.self, forKey: .eventName)

        if let packetString = try container.decodeIfPresent(String.self, forKey: .packet) {
            self.packet = packetString
        } else if let packetData = try container.decodeIfPresent(Data.self, forKey: .packet) {
            self.packet = packetData
        } else {
            self.packet = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(eventID, forKey: .eventID)
        try container.encode(eventName, forKey: .eventName)
        
        if let packet = packet {
            switch packet {
            case is String:
                try container.encode(packet as? String, forKey: .packet)
            case is Data:
                try container.encode(packet as? Data, forKey: .packet)
            default:
                throw DCError.typecastError(err: "failed to typecast to String or Data before encoding")
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case eventID
        case eventName
        case packet
    }
}
