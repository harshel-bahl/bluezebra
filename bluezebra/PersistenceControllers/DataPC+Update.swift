//
//  DataPC+Update.swift
//  bluezebra
//
//  Created by Harshel Bahl on 15/04/2023.
//

import Foundation
import CoreData

extension DataPC {
    
    public func updateMO<T: NSManagedObject & ToSafeObject>(
        entity: T.Type,
        queue: String = "background",
        useSync: Bool = false,
        property: [String],
        value: [Any?],
        predObject: [String: Any] = [:],
        predObjectNotEqual: [String: Any] = [:]
    ) async throws -> T.SafeType {
        do {
            let contextQueue = (queue == "main") ? self.mainContext : self.backgroundContext
            
            let MO = try await self.fetchMO(entity: entity,
                                            queue: queue,
                                            predObject: predObject,
                                            predObjectNotEqual: predObjectNotEqual)
            
            let SMO: T.SafeType
            
            if useSync {
                SMO = try contextQueue.performAndWait {
                    
                    for index in (0...(property.count-1)) {
                        MO.setValue(value[index], forKey: property[index])
                    }
                    
                    if contextQueue == self.mainContext {
                        try self.mainSave()
                    } else {
                        try self.backgroundSave()
                    }
                    
                    return try MO.safeObject()
                }
            } else {
                SMO = try await contextQueue.perform {
                    
                    for index in (0...(property.count-1)) {
                        MO.setValue(value[index], forKey: property[index])
                    }
                    
                    if contextQueue == self.mainContext {
                        try self.mainSave()
                    } else {
                        try self.backgroundSave()
                    }
                    
                    return try MO.safeObject()
                }
            }
            
            log.debug(message: "updated MO", function: "DataPC.updateMO", info: "entity: \(String(describing: entity))")
            
            return SMO
        } catch {
            log.error(message: "failed to update MO", function: "DataPC.updateMO", error: error, info: "entity: \(String(describing: entity))")
            throw error
        }
    }
    
    public func updateMOs<T: NSManagedObject & ToSafeObject>(
        entity: T.Type,
        queue: String = "background",
        useSync: Bool = false,
        property: [String],
        value: [Any?],
        predObject: [String: Any] = [:],
        predObjectNotEqual: [String: Any] = [:],
        datePredicates: [DatePredicate] = [],
        fetchLimit: Int? = nil,
        sortKey: String? = nil,
        sortAscending: Bool = false,
        errorOnEmpty: Bool = false
    ) async throws -> [T.SafeType] {
        do {
            let contextQueue = (queue == "main") ? self.mainContext : self.backgroundContext
            
            let MOs = try await self.fetchMOs(
                entity: entity,
                queue: queue,
                predObject: predObject,
                predObjectNotEqual: predObjectNotEqual,
                datePredicates: datePredicates,
                fetchLimit: fetchLimit,
                sortKey: sortKey,
                sortAscending: sortAscending,
                errorOnEmpty: errorOnEmpty
            )
            
            let SMOs: [T.SafeType]
            
            if useSync {
                SMOs = try contextQueue.performAndWait() {
                    
                    for MO in MOs {
                        for index in (0...(property.count-1)) {
                            MO.setValue(value[index], forKey: property[index])
                        }
                    }
                    
                    if contextQueue == self.mainContext {
                        try self.mainSave()
                    } else {
                        try self.backgroundSave()
                    }
                    
                    let SMOs = try MOs.map {
                        return try $0.safeObject()
                    }
                    
                    return SMOs
                }
            } else {
                SMOs = try await contextQueue.perform() {
                    
                    for MO in MOs {
                        for index in (0...(property.count-1)) {
                            MO.setValue(value[index], forKey: property[index])
                        }
                    }
                    
                    if contextQueue == self.mainContext {
                        try self.mainSave()
                    } else {
                        try self.backgroundSave()
                    }
                    
                    let SMOs = try MOs.map {
                        return try $0.safeObject()
                    }
                    
                    return SMOs
                }
            }
            
            log.debug(message: "updated MOs", function: "DataPC.updateMOs", info: "entity: \(String(describing: entity))")
            
            return SMOs
        } catch {
            log.error(message: "failed to update MOs", function: "DataPC.updateMOs", error: error, info: "entity: \(String(describing: entity))")
            throw error
        }
    }
}
