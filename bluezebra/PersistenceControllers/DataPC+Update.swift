//
//  DataPC+Update.swift
//  bluezebra
//
//  Created by Harshel Bahl on 15/04/2023.
//

import Foundation
import CoreData

extension DataPC {
    
    public func updateMO<T: NSManagedObject>(
        entity: T.Type,
        queue: String = "background",
        property: [String],
        value: [Any?],
        predDicEqual: [String: Any] = [:],
        predDicNotEqual: [String: Any] = [:],
        MODicEqual: [String: NSManagedObject] = [:],
        MODicNotEqual: [String: NSManagedObject] = [:],
        compoundPredicateType: String = "AND",
        prefetchKeyPaths: [String]? = nil
    ) throws -> T {
        do {
            let MO = try self.fetchMO(entity: entity,
                                            queue: queue,
                                            predDicEqual: predDicEqual,
                                            predDicNotEqual: predDicNotEqual,
                                            MODicEqual: MODicEqual,
                                            MODicNotEqual: MODicNotEqual,
                                            compoundPredicateType: compoundPredicateType,
                                            errOnMultiple: true)
            
            for index in (0...(property.count-1)) {
                MO.setValue(value[index], forKey: property[index])
            }
            
            log.debug(message: "updated MO", function: "DataPC.updateMO", info: "entity: \(String(describing: entity))")
            
            return MO
        } catch {
            log.error(message: "failed to update MO", function: "DataPC.updateMO", error: error, info: "entity: \(String(describing: entity))")
            throw error
        }
    }
    
    public func updateMOs<T: NSManagedObject>(
        entity: T.Type,
        queue: String = "background",
        property: [String],
        value: [Any?],
        predDicEqual: [String: Any] = [:],
        predDicNotEqual: [String: Any] = [:],
        MODicEqual: [String: NSManagedObject] =  [:],
        MODicNotEqual: [String: NSManagedObject] =  [:],
        datePredicates: [DatePredicate] = [],
        compoundPredicateType: String = "AND",
        fetchLimit: Int? = nil,
        batchSize: Int? = nil,
        sortKey: String? = nil,
        sortAscending: Bool = false,
        errOnEmpty: Bool = false
    ) throws -> [T] {
        do {
            let MOs = try self.fetchMOs(entity: entity,
                                        queue: queue,
                                        predDicEqual: predDicEqual,
                                        predDicNotEqual: predDicNotEqual,
                                        MODicEqual: MODicEqual,
                                        MODicNotEqual: MODicNotEqual,
                                        datePredicates: datePredicates,
                                        compoundPredicateType: compoundPredicateType,
                                        fetchLimit: fetchLimit,
                                        batchSize: batchSize,
                                        sortKey: sortKey,
                                        sortAscending: sortAscending,
                                        errOnEmpty: errOnEmpty)
            
            for MO in MOs {
                for index in (0...(property.count-1)) {
                    MO.setValue(value[index], forKey: property[index])
                }
            }
            
            log.debug(message: "updated MOs", function: "DataPC.updateMOs", info: "entity: \(String(describing: entity))")
            
            return MOs
        } catch {
            log.error(message: "failed to update MOs", function: "DataPC.updateMOs", error: error, info: "entity: \(String(describing: entity))")
            throw error
        }
    }
}
