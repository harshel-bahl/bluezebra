//
//  DataPC+Delete.swift
//  bluezebra
//
//  Created by Harshel Bahl on 15/04/2023.
//

import Foundation
import CoreData

extension DataPC {
    
    /// Generic Delete Functions
    ///
    public func deleteMO<T: NSManagedObject> (
        entity: T.Type,
        queue: String = "background",
        useSync: Bool = false,
        predObject: [String: Any] = [:],
        predObjectNotEqual: [String: Any] = [:]
    ) async throws {
        do {
            let contextQueue = (queue == "main") ? self.mainContext : self.backgroundContext
            
            let MO = try await self.fetchMO(entity: entity,
                                            queue: queue,
                                            predObject: predObject,
                                            predObjectNotEqual: predObjectNotEqual)
            
            if useSync {
                try contextQueue.performAndWait {
                    
                    contextQueue.delete(MO)
                    
                    if contextQueue == self.mainContext {
                        try self.mainSave()
                    } else {
                        try self.backgroundSave()
                    }
                }
            } else {
                try await contextQueue.perform {
                    
                    contextQueue.delete(MO)
                    
                    if contextQueue == self.mainContext {
                        try self.mainSave()
                    } else {
                        try self.backgroundSave()
                    }
                }
            }
            
            log.debug(message: "deleted MO", function: "DataPC.deleteMO", info: "entity: \(String(describing: entity))")
        } catch {
            log.error(message: "failed to delete MO", function: "DataPC.deleteMO", error: error, info: "entity: \(String(describing: entity))")
            throw error
        }
    }
    
    public func deleteMOs<T: NSManagedObject>(
        entity: T.Type,
        queue: String = "background",
        useSync: Bool = false,
        predObject: [String: Any] = [:],
        predObjectNotEqual: [String: Any] = [:],
        datePredicates: [DatePredicate] = [],
        fetchLimit: Int? = nil,
        sortKey: String? = nil,
        sortAscending: Bool = false,
        errorOnEmpty: Bool = false
    ) async throws {
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
                
                var MOCount = 0
                
                if useSync {
                    try contextQueue.performAndWait {
                        
                        for MO in MOs {
                            contextQueue.delete(MO)
                            MOCount += 1
                        }
                        
                        if contextQueue == self.mainContext {
                            try self.mainSave()
                        } else {
                            try self.backgroundSave()
                        }
                    }
                } else {
                    try await contextQueue.perform {
                        
                        for MO in MOs {
                            contextQueue.delete(MO)
                            MOCount += 1
                        }
                        
                        if contextQueue == self.mainContext {
                            try self.mainSave()
                        } else {
                            try self.backgroundSave()
                        }
                    }
                }
            
            log.debug(message: "deleted MOs", function: "DataPC.deleteMOs", info: "entity: \(String(describing: entity)), deleted: \(MOCount)")
        } catch {
            log.error(message: "failed to delete MOs", function: "DataPC.deleteMOs", error: error, info: "entity: \(String(describing: entity))")
            throw error
        }
    }
}
