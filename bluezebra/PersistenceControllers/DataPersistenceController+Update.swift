//
//  DataPC+Update.swift
//  bluezebra
//
//  Created by Harshel Bahl on 15/04/2023.
//

import Foundation
import CoreData

extension DataPC {
    
    public func updateMO<T1: NSManagedObject & ToSafeObject,
                         T2: CVarArg> (entity: T1.Type,
                                       predicateProperty: String? = nil,
                                       predicateValue: T2? = "",
                                       customPredicate: NSPredicate? = nil, 
                                       property: [String],
                                       value: [Any]) async throws -> T1.SafeType {
        var MO: T1?
        
        do {
            if let predicateProperty = predicateProperty,
               let predicateValue = predicateValue {
                let fetchedMO = try await self.fetchMOAsync(entity: entity,
                                                            predicateProperty: predicateProperty,
                                                            predicateValue: predicateValue)
                MO = fetchedMO
            } else if let customPredicate = customPredicate {
                let fetchedMO = try await self.fetchMOAsync(entity: entity,
                                                            customPredicate: customPredicate)
                MO = fetchedMO
            } else {
                let fetchedMO = try await self.fetchMOAsync(entity: entity)
                MO = fetchedMO
            }
            
            guard let MO = MO else { throw PError.failed }
            
            let sMO = try await self.backgroundContext.perform {
                for index in (0...(property.count-1)) {
                    MO.setValue(value[index], forKey: property[index])
                }
                
                try self.backgroundSave()
                
                return try MO.safeObject()
            }
            
            print("CLIENT \(DateU.shared.logTS) -- DataPC.updateMO: SUCCESS")
            
            return sMO
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- DataPC.updateMO: FAILED (entity: \(String(describing: entity))) (\(error))")
            
            throw error as? PError ?? .failed
        }
    }
    
    
    public func updateMOs<T1: NSManagedObject & ToSafeObject,
                          T2: CVarArg> (entity: T1.Type,
                                        predicateProperty: String? = nil,
                                        predicateValue: T2? = "",
                                        customPredicate: NSPredicate? = nil,
                                        property: [String],
                                        value: [Any],
                                        fetchLimit: Int? = nil,
                                        sortKey: String? = nil,
                                        sortAscending: Bool = false) async throws -> [T1.SafeType] {
        var MOs: [T1]?
        
        do {
            if let predicateProperty = predicateProperty,
               let predicateValue = predicateValue {
                let fetchedMOs = try await self.fetchMOsAsync(entity: entity,
                                                             predicateProperty: predicateProperty,
                                                             predicateValue: predicateValue,
                                                             fetchLimit: fetchLimit,
                                                             sortKey: sortKey,
                                                             sortAscending: sortAscending)
                MOs = fetchedMOs
            } else if let customPredicate = customPredicate {
                let fetchedMOs = try await self.fetchMOsAsync(entity: entity,
                                                             customPredicate: customPredicate,
                                                             fetchLimit: fetchLimit,
                                                             sortKey: sortKey,
                                                             sortAscending: sortAscending)
                MOs = fetchedMOs
            } else {
                let fetchedMOs = try await self.fetchMOsAsync(entity: entity,
                                                             fetchLimit: fetchLimit,
                                                             sortKey: sortKey,
                                                             sortAscending: sortAscending)
                MOs = fetchedMOs
            }
            
            guard let MOs = MOs else { throw PError.failed }
            
            let sMOs = try await self.backgroundContext.perform {
                
                for MO in MOs {
                    for index in (0...(property.count-1)) {
                        MO.setValue(value[index], forKey: property[index])
                    }
                }
                
                try self.backgroundSave()
                
                let sMOs = try MOs.map {
                    return try $0.safeObject()
                }
                
                return sMOs
            }
            
            print("CLIENT \(DateU.shared.logTS) -- DataPC.updateMO: SUCCESS")
            
            return sMOs
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- DataPC.updateMO: FAILED (entity: \(String(describing: entity))) (\(error))")
            
            throw error as? PError ?? .failed
        }
    }
}
