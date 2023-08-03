//
//  Settings.swift
//  bluezebra
//
//  Created by Harshel Bahl on 26/04/2023.
//

import Foundation
import CoreData

struct SSettings {
    let pin: String
    let biometricSetup: String?
}

class Settings: NSManagedObject {
    @NSManaged var pin: String?
    @NSManaged var biometricSetup: String?
}

extension Settings: ToSafeObject {
    
    func safeObject() throws -> SSettings {
        
        guard let pin = self.pin else {
            throw PError.safeMapError
        }
        
        return SSettings(pin: pin,
                         biometricSetup: self.biometricSetup)
    }
}

