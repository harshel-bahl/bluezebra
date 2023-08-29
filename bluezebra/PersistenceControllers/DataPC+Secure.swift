//
//  DataPC+Secure.swift
//  bluezebra
//
//  Created by Harshel Bahl on 29/08/2023.
//

import Foundation
import Security

extension DataPC {
    
    func storeKey(keyData: Data,
                     account: String,
                     isPublic: Bool,
                     updateIfDuplicate: Bool = true) throws {
        
        let keyClass = isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: keyClass,
            kSecAttrApplicationTag as String: account,
            kSecValueData as String: keyData
        ]
        
        var status = SecItemAdd(query as CFDictionary, nil)
        
        if updateIfDuplicate && status == errSecDuplicateItem {
            
            let updateQuery: [String: Any] = [
                        kSecClass as String: kSecClassKey,
                        kSecAttrKeyClass as String: keyClass,
                        kSecAttrApplicationTag as String: account
                    ]
            
            let attributesToUpdate: [String: Any] = [
                kSecValueData as String: keyData
            ]
            
            status = SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)
        }
        
        guard status == errSecSuccess else { throw PError.securityFailure(func: "DataPC.storeKey", err: "failed to add key") }
    }

    func updateKey(keyData: Data,
                      account: String,
                      isPublic: Bool) throws {
        
        let keyClass = isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: keyClass,
            kSecAttrApplicationTag as String: account,
            kSecReturnData as String: true
        ]
        
        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: keyData
        ]
        
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        guard status == errSecSuccess else {
            throw PError.securityFailure(func: "updateKey", err: "Failed to update key.")
        }
    }

    
    // Function to retrieve key (Public/Private)
    func retrieveKey(account: String,
                        isPublic: Bool) throws -> Data {
        
        let keyClass = isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: keyClass,
            kSecAttrApplicationTag as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject? = nil
        
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess else { throw PError.securityFailure(func: "DataPC.retrieveKey") }
        
        guard let keyData = dataTypeRef as? Data else { throw PError.typecastError(func: "DataPC.retrieveKey") }
        
        return keyData
    }
    
    // Function to delete key (Public/Private)
    func deleteKey(account: String,
                      isPublic: Bool) throws {
        
        let keyClass = isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: keyClass,
            kSecAttrApplicationTag as String: account
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess else { throw PError.securityFailure(func: "DataPC.deleteKey") }
    }
    
    func storePassword(account: String,
                      password: String,
                       updateIfDuplicate: Bool = true) throws {
        
        guard let passwordData = password.data(using: .utf8) else { throw PError.typecastError(func: "DataPC.storePassword") }
        
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account,
                                    kSecValueData as String: passwordData]
        
        var status = SecItemAdd(query as CFDictionary, nil)
        
        if updateIfDuplicate && status == errSecDuplicateItem {
                
                let updateQuery: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrAccount as String: account
                ]
                
                let attributesToUpdate: [String: Any] = [
                    kSecValueData as String: passwordData
                ]
                
                status = SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)
            }
        
        guard status == errSecSuccess else { throw PError.securityFailure(func: "DataPC.storePassword", err: "failed to add password") }
    }
    
    func retrievePassword(account: String) throws -> String {
        
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account,
                                    kSecReturnData as String: kCFBooleanTrue!,
                                    kSecMatchLimit as String: kSecMatchLimitOne]
        
        var dataTypeRef: AnyObject?
        
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        guard status == errSecSuccess else { throw PError.securityFailure(func: "DataPC.retrievePassword", err: "failed to retrieve password") }
        
        guard let data = dataTypeRef as? Data else { throw PError.typecastError(func: "DataPC.retrievePassword") }
        
        guard let password = String(data: data, encoding: .utf8) else { throw PError.typecastError(func: "DataPC.retrievePassword") }
        
        return password
    }
    
    func deletePassword(account: String) throws {
        
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrAccount as String: account]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess else { throw PError.securityFailure(func: "DataPC.deletePassword", err: "failed to delete password") }
    }
    
}

