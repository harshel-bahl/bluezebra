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
        predObject: [String: Any] = [:],
        predObjectNotEqual: [String: Any] = [:]
    ) throws {
        do {
            let contextQueue = (queue == "main") ? self.mainContext : self.backgroundContext
            
            let MO = try self.fetchMO(entity: entity,
                                            queue: queue,
            predObject: predObject,
            predObjectNotEqual: predObjectNotEqual)
            
            contextQueue.delete(MO)
            
            log.debug(message: "deleted MO from context", function: "DataPC.deleteMO", info: "entity: \(String(describing: entity))")
        } catch {
            log.error(message: "failed to delete MO from context", function: "DataPC.deleteMO", error: error, info: "entity: \(String(describing: entity))")
            throw error
        }
    }
    
    public func deleteMOs<T: NSManagedObject>(
        entity: T.Type,
        queue: String = "background",
        predObject: [String: Any] = [:],
        predObjectNotEqual: [String: Any] = [:],
        datePredicates: [DatePredicate] = [],
        fetchLimit: Int? = nil,
        errOnEmpty: Bool = false
    ) throws {
            do {
                let contextQueue = (queue == "main") ? self.mainContext : self.backgroundContext
                
                let MOs = try self.fetchMOs(
                    entity: entity,
                    queue: queue,
                    predObject: predObject,
                    predObjectNotEqual: predObjectNotEqual,
                    datePredicates: datePredicates,
                    fetchLimit: fetchLimit,
                    errOnEmpty: errOnEmpty
                )
                
                var MOCount = 0
                
                for MO in MOs {
                    contextQueue.delete(MO)
                    MOCount += 1
                }
            
            log.debug(message: "deleted MOs", function: "DataPC.deleteMOs", info: "entity: \(String(describing: entity)), deleted: \(MOCount)")
        } catch {
            log.error(message: "failed to delete MOs", function: "DataPC.deleteMOs", error: error, info: "entity: \(String(describing: entity))")
            throw error
        }
    }
}
