//
//  RUPacket.swift
//  bluezebra
//
//  Created by Harshel Bahl on 20/06/2023.
//

import Foundation

struct RUP: Codable {
    
    let uID: UUID
    let username: String
    let avatar: String
    let creationDate: Date
    let lastOnline: Date?
    
    init(uID: UUID,
         username: String,
         avatar: String,
         creationDate: Date,
         lastOnline: Date?
    ) {
         self.uID = uID
         self.username = username
         self.avatar = avatar
         self.creationDate = creationDate
         self.lastOnline = lastOnline
     }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let uIDString = try container.decode(String.self, forKey: .uID)
        guard let uID = UUID(uuidString: uIDString) else {
            throw DecodingError.dataCorruptedError(forKey: .uID, in: container, debugDescription: "Invalid UUID string")
        }
        self.uID = uID
        
        self.username = try container.decode(String.self, forKey: .username)
        self.avatar = try container.decode(String.self, forKey: .avatar)
        
        let creationDateString = try container.decode(String.self, forKey: .creationDate)
        guard let creationDate = try? DateU.shared.dateFromISOString(creationDateString) else {
            throw DecodingError.dataCorruptedError(forKey: .creationDate, in: container, debugDescription: "Invalid Date string")
        }
        self.creationDate = creationDate
        
        if let lastOnlineString = try container.decodeIfPresent(String.self, forKey: .lastOnline) {
            guard let lastOnline = try? DateU.shared.dateFromISOString(lastOnlineString) else {
                throw DecodingError.dataCorruptedError(forKey: .lastOnline, in: container, debugDescription: "Invalid Date string")
            }
            self.lastOnline = lastOnline
        } else {
            self.lastOnline = nil
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(uID.uuidString, forKey: .uID)
        try container.encode(username, forKey: .username)
        try container.encode(avatar, forKey: .avatar)
        try container.encode(DateU.shared.stringFromDate(creationDate), forKey: .creationDate)
        
        if let lastOnline = lastOnline {
            try container.encode(DateU.shared.stringFromDate(lastOnline), forKey: .lastOnline)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case uID
        case username
        case avatar
        case creationDate
        case lastOnline
    }
}
