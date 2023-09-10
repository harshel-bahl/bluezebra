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
        predDicEqual: [String: Any] = [:],
        predDicNotEqual: [String: Any] = [:],
        MODicEqual: [String: NSManagedObject] = [:],
        MODicNotEqual: [String: NSManagedObject] = [:],
        compoundPredicateType: String = "AND",
        errOnMultiple: Bool = true
    ) throws {
        do {
            let contextQueue = (queue == "main") ? self.mainContext : self.backgroundContext
            
            let MO = try self.fetchMO(entity: entity,
                                      queue: queue,
                                      predDicEqual: predDicEqual,
                                      predDicNotEqual: predDicNotEqual,
                                      MODicEqual: MODicEqual,
                                      MODicNotEqual: MODicNotEqual,
                                      compoundPredicateType: compoundPredicateType,
                                      errOnMultiple: errOnMultiple)
            
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
        predDicEqual: [String: Any] = [:],
        predDicNotEqual: [String: Any] = [:],
        MODicEqual: [String: NSManagedObject] =  [:],
        MODicNotEqual: [String: NSManagedObject] =  [:],
        datePredicates: [DatePredicate] = [],
        compoundPredicateType: String = "AND",
        fetchLimit: Int? = nil,
        errOnEmpty: Bool = false
    ) throws {
            do {
                let contextQueue = (queue == "main") ? self.mainContext : self.backgroundContext
                
                let MOs = try self.fetchMOs(entity: entity,
                                            queue: queue,
                                            predDicEqual: predDicEqual,
                                            predDicNotEqual: predDicNotEqual,
                                            MODicEqual: MODicEqual,
                                            MODicNotEqual: MODicNotEqual,
                                            datePredicates: datePredicates,
                                            compoundPredicateType: compoundPredicateType,
                                            fetchLimit: fetchLimit,
                                            errOnEmpty: errOnEmpty)
                
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
