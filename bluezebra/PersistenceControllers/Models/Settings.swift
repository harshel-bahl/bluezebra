//
//  Settings.swift
//  bluezebra
//
//  Created by Harshel Bahl on 26/04/2023.
//

import Foundation
import CoreData

struct SSettings {
    let biometricSetup: String?
}

class Settings: NSManagedObject {
    @NSManaged var biometricSetup: String?
    
    @NSManaged var user: User?
}

extension Settings: ToSafeObject {
    
    func safeObject() throws -> SSettings {
        
//        guard else {
//            throw PError.safeMapError(err: "Settings required property(s) nil")
//        }
        
        return SSettings(biometricSetup: self.biometricSetup)
    }
}

