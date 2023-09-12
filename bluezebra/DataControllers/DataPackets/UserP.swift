//
//  UserPacket.swift
//  bluezebra
//
//  Created by Harshel Bahl on 18/04/2023.
//

import Foundation

struct UserP: Codable {
    
    let uID: UUID
    let username: String
    let password: String
    let publicKey: Data
    let avatar: String
    let creationDate: Date
    
    init(uID: UUID,
         username: String,
         password: String,
         publicKey: Data,
         avatar: String,
         creationDate: Date
    ) {
        self.uID = uID
        self.username = username
        self.password = password
        self.publicKey = publicKey
        self.avatar = avatar
        self.creationDate = creationDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let uIDString = try container.decode(String.self, forKey: .uID)
        guard let uID = UUID(uuidString: uIDString) else {
            throw DecodingError.dataCorruptedError(forKey: .uID, in: container, debugDescription: "Invalid UUID string")
        }
        self.uID = uID
        
        self.username = try container.decode(String.self, forKey: .username)
        self.password = try container.decode(String.self, forKey: .password)
        let publicKeyBase64 = try container.decode(String.self, forKey: .publicKey)
        guard let publicKeyData = Data(base64Encoded: publicKeyBase64) else {
            throw DecodingError.dataCorruptedError(forKey: .publicKey, in: container, debugDescription: "Invalid base64 string for public key")
        }
        self.publicKey = publicKeyData
        self.avatar = try container.decode(String.self, forKey: .avatar)
        
        let creationDateString = try container.decode(String.self, forKey: .creationDate)
        guard let creationDate = try? DateU.shared.dateFromISOString(creationDateString) else {
            throw DecodingError.dataCorruptedError(forKey: .creationDate, in: container, debugDescription: "Invalid Date string")
        }
        self.creationDate = creationDate
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(uID.uuidString, forKey: .uID)
        try container.encode(username, forKey: .username)
        try container.encode(password, forKey: .password)
        try container.encode(publicKey.base64EncodedString(), forKey: .publicKey)
        try container.encode(avatar, forKey: .avatar)
        try container.encode(DateU.shared.stringFromDate(creationDate), forKey: .creationDate)
    }
    
    enum CodingKeys: String, CodingKey {
        case uID
        case username
        case password
        case publicKey
        case avatar
        case creationDate
    }
}

