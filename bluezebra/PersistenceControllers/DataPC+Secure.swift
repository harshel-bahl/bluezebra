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
        do {
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
            
            guard status == errSecSuccess else { throw PError.securityFailure(err: "failed to add key to keychain") }
            
            log.debug(message: "stored key in keychain", function: "DataPC.storeKey", info: "account: \(account)")
        } catch {
            log.error(message: "failed to store key in keychain", function: "DataPC.storeKey", error: error, info: "account: \(account)")
            throw error
        }
    }
    
    func updateKey(keyData: Data,
                   account: String,
                   isPublic: Bool) throws {
        do {
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
            
            guard status == errSecSuccess else { throw PError.securityFailure(err: "failed to update key in keychain") }
            
            log.debug(message: "updated key in keychain", function: "DataPC.updateKey", info: "account: \(account)")
        } catch {
            log.error(message: "failed to update key in keychain", function: "DataPC.updateKey", error: error, info: "account: \(account)")
            throw error
        }
    }
    
    
    // Function to retrieve key (Public/Private)
    func retrieveKey(account: String,
                     isPublic: Bool) throws -> Data {
        do {
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
            
            guard status == errSecSuccess else { throw PError.securityFailure(err: "failed to fetch key from keychain") }
            
            guard let keyData = dataTypeRef as? Data else { throw PError.typecastError(err: "failed to typecast dataTypeRef to Data") }
            
            log.debug(message: "retrieved key from keychain", function: "DataPC.retrieveKey", info: "account: \(account)")
            
            return keyData
        } catch {
            log.error(message: "failed to retrieve key from keychain", function: "DataPC.retrieveKey", error: error, info: "account: \(account)")
            throw error
        }
    }
    
    // Function to delete key (Public/Private)
    func deleteKey(account: String,
                   isPublic: Bool) throws {
        do {
            let keyClass = isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassKey,
                kSecAttrKeyClass as String: keyClass,
                kSecAttrApplicationTag as String: account
            ]
            
            let status = SecItemDelete(query as CFDictionary)
            
            guard status == errSecSuccess else { throw PError.securityFailure(err: "failed to delete key from keychain") }
            
            log.debug(message: "deleted key from keychain", function: "DataPC.deleteKey", info: "account: \(account)")
        } catch {
            log.error(message: "failed to delete key in keychain", function: "DataPC.deleteKey", error: error, info: "account: \(account)")
            throw error
        }
    }
    
    func storePassword(account: String,
                       password: String,
                       updateIfDuplicate: Bool = true) throws {
        do {
            guard let passwordData = password.data(using: .utf8) else { throw PError.typecastError(err: "failed to encode password in UTF8") }
            
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
            
            guard status == errSecSuccess else { throw PError.securityFailure(err: "failed to add password to keychain") }
            
            log.debug(message: "password stored in keychain", function: "DataPC.storePassword", info: "account: \(account)")
        } catch {
            log.error(message: "failed to store password in keychain", function: "DataPC.storePassword", error: error, info: "account: \(account)")
            throw error
        }
    }
    
    func retrievePassword(account: String) throws -> String {
        do {
            let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                        kSecAttrAccount as String: account,
                                        kSecReturnData as String: kCFBooleanTrue!,
                                        kSecMatchLimit as String: kSecMatchLimitOne]
            
            var dataTypeRef: AnyObject?
            
            let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
            
            guard status == errSecSuccess else { throw PError.securityFailure(err: "failed to retrieve password") }
            
            guard let data = dataTypeRef as? Data else { throw PError.typecastError(err: "failed to typecast dataTypeRef to Data") }
            
            guard let password = String(data: data, encoding: .utf8) else { throw PError.typecastError(err: "failed to encode password string to UTF8") }
            
            log.debug(function: "DataPC.retrievePassword", info: "account: \(account)")
            
            return password
        } catch {
            log.error(message: "failed to retrieve password from keychain", function: "DataPC.retrievePassword", error: error, info: "account: \(account)")
            throw error
        }
    }
    
    func deletePassword(account: String) throws {
        do {
            let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                        kSecAttrAccount as String: account]
            
            let status = SecItemDelete(query as CFDictionary)
            
            guard status == errSecSuccess else { throw PError.securityFailure(err: "key deletion failed") }
            
            log.debug(message: "deleted password from keychain", function: "DataPC.deletePassword")
        } catch {
            log.error(message: "failed to delete password from keychain", function: "DataPC.deletePassword")
            throw error
        }
    }
    
    func deleteAllKeys() throws {
        do {
            let query: [CFString: Any] = [
                kSecClass: kSecClassKey
            ]
            
            let status = SecItemDelete(query as CFDictionary)
            
            switch status {
            case errSecSuccess:
                log.debug(message: "deleted all keys", function: "DataPC.deleteAllKeys")
            case errSecItemNotFound:
                log.warning(message: "no keys found in keychain", function: "DataPC.deleteAllKeys")
            default:
                throw PError.securityFailure(err: "batch deletion failed with error code: \(status)")
            }
            
            log.debug(message: "deleted all keys from keychain", function: "DataPC.deleteAllKeys")
        } catch {
            log.error(message: "failed to delete all keys from keychain", function: "DataPC.deleteAllKeys", error: error)
            throw error
        }
    }
    
    func deleteAllPasswords() throws {
        do {
            let query: [CFString: Any] = [
                kSecClass: kSecClassGenericPassword
            ]
            
            let status = SecItemDelete(query as CFDictionary)
            
            switch status {
            case errSecSuccess:
                log.debug(message: "deleted all passwords", function: "DataPC.deleteAllPasswords")
            case errSecItemNotFound:
                log.warning(message: "no passwords found in keychain", function: "DataPC.deleteAllPasswords")
            default:
                throw PError.securityFailure(err: "batch deletion failed with error code: \(status)")
            }
            
            log.debug(message: "deleted all passwords from keychain", function: "DataPC.deleteAllPasswords")
        } catch {
            log.error(message: "failed to delete all passwords from keychain", function: "DataPC.deleteAllPasswords", error: error)
            throw error
        }
    }
    
    func deleteAllKeychainItems() throws {
        
        let keychainClasses: [CFString] = [
            kSecClassKey,
            kSecClassGenericPassword
        ]
        
        do {
            for keychainClass in keychainClasses {
                
                let query: [CFString: Any] = [
                    kSecClass: keychainClass
                ]
                
                let status = SecItemDelete(query as CFDictionary)
                
                switch status {
                case errSecSuccess:
                    log.debug(message: "deleted all items of class: \(keychainClass)", function: "DataPC.deleteAllKeychainItems")
                case errSecItemNotFound:
                    log.warning(message: "no items found to delete for class: \(keychainClass)", function: "DataPC.deleteAllKeychainItems")
                default:
                    throw PError.securityFailure(err: "Batch deletion failed for class: \(keychainClass) with error code: \(status)")
                }
            }
            
            log.debug(message: "deleted all items in keychain", function: "DataPC.deleteAllItems", info: "keychain classes: \(keychainClasses)")
        } catch {
            log.error(message: "failed to delete all items from keychain", function: "DataPC.deleteAllItems", error: error, info: "keychain classes: \(keychainClasses)")
            throw error
        }
    }
}

