//
//  SecurityUtilities.swift
//  bluezebra
//
//  Created by Harshel Bahl on 29/08/2023.
//

import Foundation
import SwiftyRSA
import CryptoKit

class SecurityU {
    
    static let shared = SecurityU()
    
    func generateRandPass(length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!£$?%^&*()_+-=<>@#~"
        var password = ""
        
        for _ in 0..<length {
            let randomIndex = Int(arc4random_uniform(UInt32(characters.count)))
            let randomCharacter = characters[characters.index(characters.startIndex, offsetBy: randomIndex)]
            password.append(randomCharacter)
        }
        
        return password
    }
    
    func generateKeyPair(sizeInBits: Int = 2048) throws -> [String: Data] {
        do {
            let keyPair = try SwiftyRSA.generateRSAKeyPair(sizeInBits: sizeInBits)
            
            let privateKey = keyPair.privateKey
            let publicKey = keyPair.publicKey
            
            let privateKeyData = try privateKey.data()
            let publicKeyData = try publicKey.data()
    
            return ["publicKey": publicKeyData, "privateKey": privateKeyData]
        } catch {
            throw DCError.securityFailure(err: String(describing: error))
        }
    }
    
    // encryptRSA
    // sender uses recipient's public key to encrypt data
    func encryptRSA(str: String,
                    publicKey: PublicKey) -> String? {
        do {
            let clear = try ClearMessage(string: str, using: .utf8)
            let encrypted = try clear.encrypted(with: publicKey, padding: .PKCS1)
            return encrypted.base64String
        } catch {
            print("Got an error creating the RSA key: \(error)")
            return nil
        }
    }

    func decryptRSA(encryptedStr: String,
                    privateKey: PrivateKey) -> String? {
        do {
            let encrypted = try EncryptedMessage(base64Encoded: encryptedStr)
            let clear = try encrypted.decrypted(with: privateKey, padding: .PKCS1)
            return try clear.string(encoding: .utf8)
        } catch {
            print("Got an error decrypting the RSA key: \(error)")
            return nil
        }
    }
    
    func generateAESKey(size: SymmetricKeySize = .bits256) -> SymmetricKey {
        return SymmetricKey(size: size)
    }

    func encryptAES(data: Data,
                    symmetricKey: SymmetricKey) throws -> Data {
        do {
            let sealedBox = try AES.GCM.seal(data, using: symmetricKey)
            
            guard let encryptedData = sealedBox.combined else { throw DCError.securityFailure(err: "encrypting data failed") }
                    
            log.debug(message: "successfully encrypted data", function: "SecurityU.encryptAES")
            
            return encryptedData
        } catch {
            
            throw error
        }
    }

    func decryptAES(encryptedData: Data,
                    symmetricKey: SymmetricKey) throws -> Data {
        do {
            let sealedBox = try AES.GCM.SealedBox(combined: encryptedData)
            
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            
            return decryptedData
        } catch {
            throw error
        }
    }
    
    
}
