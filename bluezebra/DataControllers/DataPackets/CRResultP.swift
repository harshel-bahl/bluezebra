//
//  CRResult.swift
//  bluezebra
//
//  Created by Harshel Bahl on 11/08/2023.
//

import Foundation

struct CRResultP: Codable {
    
    let requestID: UUID
    let result: Bool
    let channelID: String
    let symmetricKey: String
    let creationDate: Date
    
    init(requestID: UUID,
         result: Bool,
         channelID: String,
         symmetricKey: String,
         creationDate: Date
    ) {
            self.requestID = requestID
            self.result = result
            self.channelID = channelID
            self.symmetricKey = symmetricKey
            self.creationDate = creationDate
        }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let requestIDString = try container.decode(String.self, forKey: .requestID)
        guard let requestID = UUID(uuidString: requestIDString) else {
            throw DecodingError.dataCorruptedError(forKey: .requestID, in: container, debugDescription: "Invalid UUID string")
        }
        self.requestID = requestID

        self.result = try container.decode(Bool.self, forKey: .result)
        self.channelID = try container.decode(String.self, forKey: .channelID)
        self.symmetricKey = try container.decode(String.self, forKey: .symmetricKey)
        
        let creationDateString = try container.decode(String.self, forKey: .creationDate)
        guard let creationDate = try? DateU.shared.dateFromString(creationDateString) else {
            throw DecodingError.dataCorruptedError(forKey: .creationDate, in: container, debugDescription: "Invalid Date string")
        }
        self.creationDate = creationDate
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(requestID.uuidString, forKey: .requestID)
        try container.encode(result, forKey: .result)
        try container.encode(channelID, forKey: .channelID)
        try container.encode(symmetricKey, forKey: .symmetricKey)
        try container.encode(DateU.shared.stringFromDate(creationDate), forKey: .creationDate)
    }

    enum CodingKeys: String, CodingKey {
        case requestID
        case result
        case channelID
        case symmetricKey
        case creationDate
    }
}

