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
    
    /// fetchMOAsync: fetches managed object and returns it asynchronously
    ///
    public func fetchMO<T1: NSManagedObject,
                        T2: CVarArg>(entity: T1.Type,
                                     queue: String = "background",
                                     predicateProperty: String? = nil,
                                     predicateValue: T2? = "",
                                     customPredicate: NSPredicate? = nil) async throws -> T1 {
        let contextQueue: NSManagedObjectContext
        
        if queue=="main" {
            contextQueue = self.mainContext
        } else {
            contextQueue = self.backgroundContext
        }
        
        let entityName = String(describing: entity)
        
        let fetchRequest = NSFetchRequest<T1>(entityName: entityName)
        
        if let predicateProperty=predicateProperty,
           let predicateValue=predicateValue {
            fetchRequest.predicate = NSPredicate(format: "\(predicateProperty) == %@", predicateValue)
        } else if let customPredicate = customPredicate {
            fetchRequest.predicate = customPredicate
        }
        
        do {
            let MOs = try await contextQueue.perform {
                return try contextQueue.fetch(fetchRequest)
            }
            
            if MOs.count > 1 { throw PError.multipleRecords(func: "DataPC.fetchMO", err: "entity: \(entity)") }
            
            let MO: T1
            
            guard let firstMO = MOs.first else { throw PError.noRecordExists(func: "DataPC.fetchMO", err: "entity: \(entity)") }
            MO = firstMO
            
#if DEBUG
            DataU.shared.handleSuccess(function: "DataPC.fetchMO", info: "entity: \(String(describing: entity))")
#endif
            
            return MO
        } catch {
            if let error = error as? PError {
                throw error
            } else {
                throw PError.persistenceError(func: "DataPC.fetchMO", err: error.localizedDescription)
            }
        }
    }
    
    public func fetchMOs<T1: NSManagedObject,
                         T2: CVarArg>(entity: T1.Type,
                                      queue: String = "background",
                                      predicateProperty: String? = nil,
                                      predicateValue: T2? = "",
                                      customPredicate: NSPredicate? = nil,
                                      fetchLimit: Int? = nil,
                                      sortKey: String? = nil,
                                      sortAscending: Bool = false) async throws -> [T1] {
        var contextQueue = self.backgroundContext
        
        if queue=="main" {
            contextQueue = self.mainContext
        }
        
        let entityName = String(describing: entity)
        
        let fetchRequest = NSFetchRequest<T1>(entityName: entityName)
        
        if let predicateProperty=predicateProperty,
           let predicateValue=predicateValue {
            if let predicateValue = predicateValue as? Bool {
                fetchRequest.predicate = NSPredicate(format: "\(predicateProperty) == %@", NSNumber(value: predicateValue))
            } else {
                fetchRequest.predicate = NSPredicate(format: "\(predicateProperty) == %@", predicateValue)
            }
        } else if let customPredicate = customPredicate {
            fetchRequest.predicate = customPredicate
        }
        
        if let fetchLimit = fetchLimit {
            fetchRequest.fetchLimit=fetchLimit
        }
        
        if let sortKey = sortKey {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: sortAscending)]
        }
        
        do {
            let MOs = try await contextQueue.perform {
                return try contextQueue.fetch(fetchRequest)
            }
            
#if DEBUG
            DataU.shared.handleSuccess(function: "DataPC.fetchMOs", info: "entity: \(String(describing: entity)), resultCount: \(MOs.count)")
#endif
            
            return MOs
        } catch {
            if let error = error as? PError {
                throw error
            } else {
                throw PError.persistenceError(func: "DataPC.fetchMOs", err: error.localizedDescription)
            }
        }
    }
    
    /// fetchSMOAsync: fetches managed object and returns its safe object asynchronously
    ///
    public func fetchSMO<T1: NSManagedObject & ToSafeObject,
                         T2: CVarArg>(entity: T1.Type,
                                      queue: String = "main",
                                      predicateProperty: String? = nil,
                                      predicateValue: T2? = "",
                                      customPredicate: NSPredicate? = nil) async throws -> T1.SafeType {
        var contextQueue = self.mainContext
        
        if queue=="background" {
            contextQueue = self.backgroundContext
        }
        
        let entityName = String(describing: entity)
        
        let fetchRequest = NSFetchRequest<T1>(entityName: entityName)
        
        if let predicateProperty=predicateProperty,
           let predicateValue=predicateValue {
            fetchRequest.predicate = NSPredicate(format: "\(predicateProperty) == %@", predicateValue)
        } else if let customPredicate = customPredicate {
            fetchRequest.predicate = customPredicate
        }
        
        do {
            let MOs = try await contextQueue.perform {
                return try contextQueue.fetch(fetchRequest)
            }
            
            if MOs.count > 1 { throw PError.multipleRecords(func: "DataPC.fetchSMO", err: "entity: \(entity)") }
            
            guard let MO = MOs.first else { throw PError.noRecordExists(func: "DataPC.fetchSMO", err: "entity: \(entity)") }
            
            let SMO = try MO.safeObject()
            
            
#if DEBUG
            DataU.shared.handleSuccess(function: "DataPC.fetchSMO", info: "entity: \(String(describing: entity))")
#endif
            
            return SMO
        } catch {
            if let error = error as? PError {
                throw error
            } else {
                throw PError.persistenceError(func: "DataPC.fetchSMO", err: error.localizedDescription)
            }
        }
    }
    
    /// fetchSMOsAsync: fetches managed objects and returns their safe objects asynchronously
    ///
    public func fetchSMOs<T1: NSManagedObject & ToSafeObject,
                          T2: CVarArg>(entity: T1.Type,
                                       queue: String = "main",
                                       predicateProperty: String? = nil,
                                       predicateValue: T2? = "",
                                       customPredicate: NSPredicate? = nil,
                                       fetchLimit: Int? = nil,
                                       sortKey: String? = nil,
                                       sortAscending: Bool = false) async throws -> [T1.SafeType] {
        var contextQueue = self.mainContext
        
        if queue=="background" {
            contextQueue = self.backgroundContext
        }
        
        let entityName = String(describing: entity)
        let fetchRequest = NSFetchRequest<T1>(entityName: entityName)
        
        if let predicateProperty=predicateProperty,
           let predicateValue=predicateValue {
            if let predicateValue = predicateValue as? Bool {
                fetchRequest.predicate = NSPredicate(format: "\(predicateProperty) == %@", NSNumber(value: predicateValue))
            } else {
                fetchRequest.predicate = NSPredicate(format: "\(predicateProperty) == %@", predicateValue)
            }
        } else if let customPredicate = customPredicate {
            fetchRequest.predicate = customPredicate
        }
        
        if let fetchLimit = fetchLimit {
            fetchRequest.fetchLimit = fetchLimit
        }
        
        if let sortKey = sortKey {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: sortAscending)]
        }
        
        do {
            let MOs = try await contextQueue.perform {
                return try contextQueue.fetch(fetchRequest)
            }
            
#if DEBUG
            DataU.shared.handleSuccess(function: "DataPC.fetchSMOs", info: "entity: \(String(describing: entity)), resultCount: \(MOs.count)")
#endif
            
            let SMOs = try MOs.map {
                return try $0.safeObject()
            }
            
            return SMOs
        } catch {
            if let error = error as? PError {
                throw error
            } else {
                throw PError.persistenceError(func: "DataPC.fetchSMOs", err: error.localizedDescription)
            }
        }
    }
}
