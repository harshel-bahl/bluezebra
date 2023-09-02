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

    internal func createPredicate(_ predObject: [String: Any], comparison: String) throws -> NSPredicate {
        
        let subpredicates = try predObject.map { key, value -> NSPredicate in
            
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
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
    }
    
    public func fetchMO<T: NSManagedObject>(
        entity: T.Type,
        queue: String = "background",
        predObject: [String: Any] = [:],
        predObjectNotEqual: [String: Any] = [:]
    ) async throws -> T {
        do {
            let contextQueue = (queue == "main") ? self.mainContext : self.backgroundContext
            
            let MOs = try await contextQueue.perform {
                
                let fetchRequest = NSFetchRequest<T>(entityName: String(describing: entity))
                
                var predicates: [NSPredicate] = []
                
                if !predObject.isEmpty {
                    predicates.append(try self.createPredicate(predObject, comparison: "=="))
                }
                
                if !predObjectNotEqual.isEmpty {
                    predicates.append(try self.createPredicate(predObjectNotEqual, comparison: "!="))
                }
                
                if !predicates.isEmpty {
                    fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                }
                
                return try contextQueue.fetch(fetchRequest)
            }
            
            if MOs.count > 1 { throw PError.multipleRecords() }
            
            guard let MO = MOs.first else { throw PError.noRecordExists() }
            
            log.debug(message: "fetched MO", function: "DataPC.fetchMO", info: "entity: \(String(describing: entity))")
            
            return MO
        } catch {
            log.error(message: "failed to fetch MO", function: "DataPC.fetchMO", error: error, info: "entity: \(String(describing: entity))")
            throw error
        }
    }

    public func fetchMOs<T1: NSManagedObject>(
        entity: T1.Type,
        queue: String = "background",
        predObject: [String: Any] = [:],
        predObjectNotEqual: [String: Any] = [:],
        datePredicates: [DatePredicate] = [],
        fetchLimit: Int? = nil,
        sortKey: String? = nil,
        sortAscending: Bool = false,
        errorOnEmpty: Bool = false
    ) async throws -> [T1] {
        do {
            let contextQueue = (queue == "main") ? self.mainContext : self.backgroundContext
            
            let MOs = try await contextQueue.perform {
                
                let fetchRequest = NSFetchRequest<T1>(entityName: String(describing: entity))
                
                var predicates: [NSPredicate] = []
                
                if !predObject.isEmpty {
                    predicates.append(try self.createPredicate(predObject, comparison: "=="))
                }
                
                if !predObjectNotEqual.isEmpty {
                    predicates.append(try self.createPredicate(predObjectNotEqual, comparison: "!="))
                }
                
                predicates += datePredicates.map { self.createDatePredicate($0) }
                
                if !predicates.isEmpty {
                    fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                }
                
                fetchRequest.fetchLimit = fetchLimit ?? 0
                
                if let sortKey = sortKey {
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: sortAscending)]
                }
                
                return try contextQueue.fetch(fetchRequest)
            }
            
            if errorOnEmpty {
                guard MOs.isEmpty else { throw PError.noRecordExists() }
            }
            
            log.debug(message: "fetched MOs", function: "DataPC.fetchMOs", info: "entity: \(String(describing: entity))")
            
            return MOs
        } catch {
            log.error(message: "failed to fetch MOs", function: "DataPC.fetchMOs", error: error, info: "entity: \(String(describing: entity))")
            throw error
        }
    }
    
    public func fetchSMO<T1: NSManagedObject & ToSafeObject>(
        entity: T1.Type,
        queue: String = "main",
        predObject: [String: Any] = [:],
        predObjectNotEqual: [String: Any] = [:]
    ) async throws -> T1.SafeType {
        do {
            let contextQueue = (queue == "main") ? self.mainContext : self.backgroundContext
            
            let MOs = try await contextQueue.perform {
                
                let fetchRequest = NSFetchRequest<T1>(entityName: String(describing: entity))
                
                var predicates: [NSPredicate] = []
                
                if !predObject.isEmpty {
                    predicates.append(try self.createPredicate(predObject, comparison: "=="))
                }
                
                if !predObjectNotEqual.isEmpty {
                    predicates.append(try self.createPredicate(predObjectNotEqual, comparison: "!="))
                }
                
                if !predicates.isEmpty {
                    fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                }
                
                return try contextQueue.fetch(fetchRequest)
            }
            
            if MOs.count > 1 {
                throw PError.multipleRecords()
            }
            
            guard let MO = MOs.first else {
                throw PError.noRecordExists()
            }
            
            let SMO = try MO.safeObject()
            
            log.debug(message: "fetched SMO", function: "DataPC.fetchSMO", info: "entity: \(String(describing: entity))")
            
            return SMO
        } catch {
            log.error(message: "failed to fetch SMO", function: "DataPC.fetchSMO", error: error, info: "entity: \(String(describing: entity))")
            throw error
        }
    }
    
    public func fetchSMOs<T1: NSManagedObject & ToSafeObject>(
        entity: T1.Type,
        queue: String = "main",
        predObject: [String: Any] = [:],
        predObjectNotEqual: [String: Any] = [:],
        datePredicates: [DatePredicate] = [],
        fetchLimit: Int? = nil,
        sortKey: String? = nil,
        sortAscending: Bool = false
    ) async throws -> [T1.SafeType] {
        do {
            let contextQueue = (queue == "main") ? self.mainContext : self.backgroundContext
            
            let MOs = try await contextQueue.perform {
                
                let fetchRequest = NSFetchRequest<T1>(entityName: String(describing: entity))
                
                var predicates: [NSPredicate] = []
                
                if !predObject.isEmpty {
                    predicates.append(try self.createPredicate(predObject, comparison: "=="))
                }
                
                if !predObjectNotEqual.isEmpty {
                    predicates.append(try self.createPredicate(predObjectNotEqual, comparison: "!="))
                }
                
                predicates += datePredicates.map { self.createDatePredicate($0) }
                
                if !predicates.isEmpty {
                    fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
                }
                
                fetchRequest.fetchLimit = fetchLimit ?? 0
                
                if let sortKey = sortKey {
                    fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: sortAscending)]
                }
                
                return try contextQueue.fetch(fetchRequest)
            }
            
            log.debug(message: "fetched SMOs", function: "DataPC.fetchSMOs", info: "entity: \(String(describing: entity))")
            
            let SMOs = try MOs.map {
                return try $0.safeObject()
            }
            
            return SMOs
        } catch {
            log.error(message: "failed to fetch SMOs", function: "DataPC.fetchSMOs", error: error, info: "entity: \(String(describing: entity))")
            throw error
        }
    }
}
