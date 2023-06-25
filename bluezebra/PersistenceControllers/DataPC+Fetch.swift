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
    public func fetchMOAsync<T1: NSManagedObject,
                             T2: CVarArg>(entity: T1.Type,
                                          queue: String = "background",
                                          predicateProperty: String? = nil,
                                          predicateValue: T2? = "",
                                          customPredicate: NSPredicate? = nil,
                                          silentFail: Bool = false) async throws -> T1 {
        var contextQueue = self.backgroundContext
        
        if queue=="main" {
            contextQueue = self.mainContext
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
            
            if MOs.count > 1 { throw PError.multipleRecords }
            guard let MO = MOs.first else { throw PError.noRecordExists }
            
            print("CLIENT \(DateU.shared.logTS) -- DataPC.fetchMO: SUCCESS (entity: \(entityName))")
            
            return MO
        } catch {
            if !silentFail {
                print("CLIENT \(DateU.shared.logTS) -- DataPC.fetchMO: FAILED (entity: \(entityName)) (\(error))")
            }
            throw PError.failed
        }
    }
    
    public func fetchMOsAsync<T1: NSManagedObject,
                              T2: CVarArg>(entity: T1.Type,
                                           queue: String = "background",
                                           predicateProperty: String? = nil,
                                           predicateValue: T2? = "",
                                           customPredicate: NSPredicate? = nil,
                                           fetchLimit: Int? = nil,
                                           sortKey: String? = nil,
                                           sortAscending: Bool = false,
                                           silentFail: Bool = false) async throws -> [T1] {
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
            
            print("CLIENT \(DateU.shared.logTS) -- DataPC.fetchMO: SUCCESS (entity: \(entityName))")
            
            return MOs
        } catch {
            if !silentFail {
                print("CLIENT \(DateU.shared.logTS) -- DataPC.fetchMO: FAILED (entity: \(entityName)) (\(error))")
            }
            throw PError.failed
        }
    }
    
    /// fetchSMOAsync: fetches managed object and returns its safe object asynchronously
    ///
    public func fetchSMOAsync<T1: NSManagedObject & ToSafeObject,
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
            
            if MOs.count > 1 { throw PError.multipleRecords }
            guard let MO = MOs.first else { throw PError.noRecordExists }
            
            print("CLIENT \(DateU.shared.logTS) -- DataPC.fetchSMOAsync: SUCCESS (entity: \(entityName))")
            
            let sMO = try MO.safeObject()
            
            return sMO
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- DataPC.fetchSMOAsync: FAILED (entity: \(entityName)) (\(error))")
            throw PError.failed
        }
    }
    
    /// fetchSMOsAsync: fetches managed objects and returns their safe objects asynchronously
    ///
    public func fetchSMOsAsync<T1: NSManagedObject & ToSafeObject,
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
            fetchRequest.fetchLimit=fetchLimit
        }
        
        if let sortKey = sortKey {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: sortAscending)]
        }
        
        do {
            var MOs = try await contextQueue.perform {
                return try contextQueue.fetch(fetchRequest)
            }
            
            print("CLIENT \(DateU.shared.logTS) -- DataPC.fetchSMOsAsync: SUCCESS (entity: \(entityName)) (fetched: \(MOs.count))")
            
            let sMOs = try MOs.map {
                return try $0.safeObject()
            }
            
            return sMOs
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- DataPC.fetchSMOsAsync: FAILED (entity: \(entityName)) (\(error))")
            throw PError.failed
        }
    }
    
    
    /// fetchSMO: fetches managed object and returns its safe object
    ///
    public func fetchSMO<T1: NSManagedObject & ToSafeObject,
                         T2: CVarArg>(entity: T1.Type,
                                      queue: String = "main",
                                      predicateProperty: String? = nil,
                                      predicateValue: T2? = "",
                                      customPredicate: NSPredicate? = nil,
                                      completion: @escaping (Result<T1.SafeType, PError>)->()) {
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
        
        contextQueue.perform {
            do {
                let MOs = try contextQueue.fetch(fetchRequest)
                
                if MOs.count > 1 { throw PError.multipleRecords }
                guard let MO = MOs.first else { throw PError.noRecordExists }
                
                print("CLIENT \(DateU.shared.logTS) -- DataPC.fetchSMO: SUCCESS (entity: \(entityName))")
                
                let sMO = try MO.safeObject()
                
                DispatchQueue.main.async {
                    completion(.success(sMO))
                }
            } catch {
                print("CLIENT \(DateU.shared.logTS) -- DataPC.fetchSMO: FAILED (entity: \(entityName)) (\(error))")
                
                DispatchQueue.main.async {
                    completion(.failure(error as? PError ?? .failed))
                }
            }
        }
    }
    
    /// fetchSMOs: fetches managed objects and returns their safe objects
    /// 
    public func fetchSMOs<T1: NSManagedObject & ToSafeObject,
                          T2: CVarArg>(entity: T1.Type,
                                       queue: String = "main",
                                       predicateProperty: String? = nil,
                                       predicateValue: T2? = "",
                                       customPredicate: NSPredicate? = nil,
                                       fetchLimit: Int? = nil,
                                       sortKey: String? = nil,
                                       sortAscending: Bool = false,
                                       completion: @escaping (Result<[T1.SafeType], PError>)->()) {
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
        
        if let fetchLimit = fetchLimit {
            fetchRequest.fetchLimit=fetchLimit
        }
        
        if let sortKey = sortKey {
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: sortKey, ascending: sortAscending)]
        }
        
        contextQueue.perform {
            do {
                let MOs = try contextQueue.fetch(fetchRequest)
                
                print("CLIENT \(DateU.shared.logTS) -- DataPC.fetchSMOs: SUCCESS (entity: \(entityName)) (fetched: \(MOs.count))")
                
                let sMOs = try MOs.map {
                    return try $0.safeObject()
                }
                
                DispatchQueue.main.async {
                    completion(.success(sMOs))
                }
            } catch {
                print("CLIENT \(DateU.shared.logTS) -- DataPC.fetchSMOs: FAILED (entity: \(entityName)) (\(error))")
                
                DispatchQueue.main.async {
                    completion(.failure(error as? PError ?? .failed))
                }
            }
        }
    }
}
