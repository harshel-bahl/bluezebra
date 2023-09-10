//
//  CRPacket.swift
//  bluezebra
//
//  Created by Harshel Bahl on 18/04/2023.
//

import Foundation

struct CRP: Codable {
    
    let requestID: UUID
    let requestDate: Date
    let RU: RUP
    
    init(requestID: UUID,
         requestDate: Date,
         RU: RUP
    ) {
        self.requestID = requestID
        self.requestDate = requestDate
        self.RU = RU
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let requestIDString = try container.decode(String.self, forKey: .requestID)
        guard let requestID = UUID(uuidString: requestIDString) else {
            throw DecodingError.dataCorruptedError(forKey: .requestID, in: container, debugDescription: "Invalid UUID string")
        }
        self.requestID = requestID

        let requestDateString = try container.decode(String.self, forKey: .requestDate)
        guard let requestDate = try? DateU.shared.dateFromString(requestDateString) else {
            throw DecodingError.dataCorruptedError(forKey: .requestDate, in: container, debugDescription: "Invalid Date string")
        }
        self.requestDate = requestDate

        self.RU = try container.decode(RUP.self, forKey: .RU)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(requestID.uuidString, forKey: .requestID)
        try container.encode(DateU.shared.stringFromDate(requestDate), forKey: .requestDate)
        try container.encode(RU, forKey: .RU)
    }

    enum CodingKeys: String, CodingKey {
        case requestID
        case requestDate
        case RU
    }
}

