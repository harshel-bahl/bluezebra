//
//  DataPC+Fetch.swift
//  bluezebra
//
//  Created by Harshel Bahl on 15/04/2023.
//

import Foundation
import CoreData

extension DataPC {
    
    /// Generic Fetch Functions
    ///
    public struct DatePredicate {
        var key: String
        var date: Date
        var isAbove: Bool
    }
    
    internal func createDatePredicate(_ datePredicate: DatePredicate) -> NSPredicate {
        let comparison = datePredicate.isAbove ? ">=" : "<="
        let predicateFormat = "\(datePredicate.key) \(comparison) %@"
        return NSPredicate(format: predicateFormat, argumentArray: [datePredicate.date])
    }
    
    internal func createPredicate(_ predDic: [String: Any], comparison: String) throws -> [NSPredicate] {
        
        return try predDic.map { key, value -> NSPredicate in
            
            let predicateFormat = "\(key) \(comparison) %@"
            
            let cvarArgValue: CVarArg
            if let boolValue = value as? Bool {
                cvarArgValue = NSNumber(value: boolValue)
            } else if let otherValue = value as? CVarArg {
                cvarArgValue = otherValue
            } else {
                throw PError.invalidRequest(err: "the value must conform to CVarArg")
            }
            
            let argumentArray: [CVarArg] = [cvarArgValue]
            
            return NSPredicate(format: predicateFormat, argumentArray: argumentArray)
        }
    }
    
    internal func createPredicate(_ MODic: [String: NSManagedObject], comparison: String) -> [NSPredicate] {
        
        return MODic.map { key, value -> NSPredicate in
            
            let predicateFormat = "\(key) \(comparison) %@"
            
            return NSPredicate(format: predicateFormat, value)
        }
    }
    
    public func fetchMO<T: NSManagedObject>(
        entity: T.Type,
        queue: String = "main",
        predDicEqual: [String: Any] = [:],
        predDicNotEqual: [String: Any] = [:],
        MODicEqual: [String: NSManagedObject] = [:],
        MODicNotEqual: [String: NSManagedObject] = [:],
        compoundPredicateType: String = "AND",
        prefetchKeyPaths: [String]? = nil,
        errOnMultiple: Bool = true
    ) throws -> T {
        do {
            let contextQueue = (queue == "main") ? self.mainContext : self.backgroundContext
            
            let fetchRequest = NSFetchRequest<T>(entityName: String(describing: entity))
            
            var predicates: [NSPredicate] = []
            
            if !predDicEqual.isEmpty {
                predicates.append(contentsOf: try self.createPredicate(predDicEqual, comparison: "=="))
            }
            
            if !predDicNotEqual.isEmpty {
                predicates.append(contentsOf: try self.createPredicate(predDicNotEqual, comparison: "!="))
            }
            
            if !MODicEqual.isEmpty {
                predicates.append(contentsOf: self.createPredicate(MODicEqual, comparison: "=="))
            }
            
            if !MODicNotEqual.isEmpty {
                predicates.append(contentsOf: self.createPredicate(MODicNotEqual, comparison: "!="))
            }
            
            if !predicates.isEmpty {
                if compoundPredicateType == "AND" {
                    fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                } else if compoundPredicateType == "OR" {
                    fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
                }
            }
            
            if let prefetchKeyPaths = prefetchKeyPaths {
                fetchRequest.relationshipKeyPathsForPrefetching = prefetchKeyPaths
            }
            
            let MOs = try contextQueue.fetch(fetchRequest)
            
            if MOs.count > 1 && errOnMultiple { throw PError.multipleRecords() }
            
            guard let MO = MOs.first else { throw PError.noRecordExists() }
            
            log.debug(message: "fetched MO", function: "DataPC.fetchMO", info: "entity: \(String(describing: entity))")
            
            return MO
            
        } catch {
            log.error(message: "failed to fetch MO", function: "DataPC.fetchMO", error: error, info: "entity: \(String(describing: entity))")
            throw error
        }
    }
    
    public func fetchMOs<T: NSManagedObject>(
        entity: T.Type,
        queue: String = "main",
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
        prefetchKeyPaths: [String]? = nil,
        errOnEmpty: Bool = false
    ) throws -> [T] {
        do {
            let contextQueue = (queue == "main") ? self.mainContext : self.backgroundContext
            
            let fetchRequest = NSFetchRequest<T>(entityName: String(describing: entity))
            
            var predicates: [NSPredicate] = []
            
            if !predDicEqual.isEmpty {
                predicates.append(contentsOf: try self.createPredicate(predDicEqual, comparison: "=="))
            }
            
            if !predDicNotEqual.isEmpty {
                predicates.append(contentsOf: try self.createPredicate(predDicNotEqual, comparison: "!="))
            }
            
            if !MODicEqual.isEmpty {
                predicates.append(contentsOf: self.createPredicate(MODicEqual, comparison: "=="))
            }
            
            if !MODicNotEqual.isEmpty {
                predicates.append(contentsOf: self.createPredicate(MODicNotEqual, comparison: "!="))
            }
            
            predicates += datePredicates.map { self.createDatePredicate($0) }
            
            if !predicates.isEmpty {
                if compoundPredicateType == "AND" {
                    fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                } else if compoundPredicateType == "OR" {
                    fetchRequest.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
                }
            }
            
            if let fetchLimit = fetchLimit {
                fetchRequest.fetchLimit = fetchLimit
            }
            
            if let batchSize = batchSize {
                fetchRequest.fetchBatchSize = batchSize
            }
            
            if let sortKey = sortKey {
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: sortAscending)]
            }
            
            if let prefetchKeyPaths = prefetchKeyPaths {
                fetchRequest.relationshipKeyPathsForPrefetching = prefetchKeyPaths
            }
            
            let MOs = try contextQueue.fetch(fetchRequest)
            
            if errOnEmpty {
                guard MOs.isEmpty else { throw PError.noRecordExists() }
            }
            
            log.debug(message: "fetched MOs", function: "DataPC.fetchMOs", info: "entity: \(String(describing: entity))")
            
            return MOs
            
        } catch {
            log.error(message: "failed to fetch MOs", function: "DataPC.fetchMOs", error: error, info: "entity: \(String(describing: entity))")
            throw error
        }
    }
    
    public func fetchSMO<T: NSManagedObject & ToSafeObject>(
        entity: T.Type,
        queue: String = "main",
        predDicEqual: [String: Any] = [:],
        predDicNotEqual: [String: Any] = [:],
        MODicEqual: [String: NSManagedObject] = [:],
        MODicNotEqual: [String: NSManagedObject] = [:],
        compoundPredicateType: String = "AND",
        prefetchKeyPaths: [String]? = nil,
        errOnMultiple: Bool = true
    ) async throws -> T.SafeType {
        do {
            let contextQueue = (queue == "main") ? self.mainContext : self.backgroundContext
            
            let SMO = try await contextQueue.perform {
                
                let MO = try self.fetchMO(entity: entity,
                                          queue: queue,
                                          predDicEqual: predDicEqual,
                                          predDicNotEqual: predDicNotEqual,
                                          MODicEqual: MODicEqual,
                                          MODicNotEqual: MODicNotEqual,
                                          compoundPredicateType: compoundPredicateType,
                                          prefetchKeyPaths: prefetchKeyPaths,
                                          errOnMultiple: errOnMultiple)
                
                return try MO.safeObject()
            }
            
            log.debug(message: "fetched SMO", function: "DataPC.fetchSMO", info: "entity: \(String(describing: entity))")
            
            return SMO
            
        } catch {
            log.error(message: "failed to fetch SMO", function: "DataPC.fetchSMO", error: error, info: "entity: \(String(describing: entity))")
            throw error
        }
    }
    
    public func fetchSMOs<T: NSManagedObject & ToSafeObject>(
        entity: T.Type,
        queue: String = "main",
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
        prefetchKeyPaths: [String]? = nil,
        errOnEmpty: Bool = false
    ) async throws -> [T.SafeType] {
        do {
            let contextQueue = (queue == "main") ? self.mainContext : self.backgroundContext
            
            let SMOs = try await contextQueue.perform {
                
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
                                            prefetchKeyPaths: prefetchKeyPaths,
                                            errOnEmpty: errOnEmpty)
                
                let SMOs = try MOs.map { try $0.safeObject() }
                
                return SMOs
            }
            
            log.debug(message: "fetched SMOs", function: "DataPC.fetchSMOs", info: "entity: \(String(describing: entity))")
            
            return SMOs
            
        } catch {
            log.error(message: "failed to fetch SMOs", function: "DataPC.fetchSMOs", error: error, info: "entity: \(String(describing: entity))")
            throw error
        }
    }
}
