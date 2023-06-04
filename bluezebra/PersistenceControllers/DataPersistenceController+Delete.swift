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
    public func fetchDeleteMOAsync<T1: NSManagedObject,
                                   T2: CVarArg>(entity: T1.Type,
                                                queue: String = "background",
                                                predicateProperty: String? = nil,
                                                predicateValue: T2? = "",
                                                customPredicate: NSPredicate? = nil) async throws {
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
        
        try await contextQueue.perform {
            do {
                let MOs = try contextQueue.fetch(fetchRequest)
                
                if MOs.count > 1 { throw PError.multipleRecords }
                guard let MO = MOs.first else { throw PError.noRecordExists }
                
                contextQueue.delete(MO)
                
                try contextQueue.save()
                
                print("CLIENT \(Date.now) -- DataPC.fetchDeleteMOAsync: SUCCESS (entity: \(entityName))")
            } catch {
                print("CLIENT \(Date.now) -- DataPC.fetchDeleteMOAsync: FAILED (entity: \(entityName)) (\(error))")
                throw PError.failed
            }
        }
    }
    
    public func fetchDeleteMOsAsync<T1: NSManagedObject,
                                    T2: CVarArg>(entity: T1.Type,
                                                 queue: String = "background",
                                                 predicateProperty: String? = nil,
                                                 predicateValue: T2? = "",
                                                 customPredicate: NSPredicate? = nil) async throws {
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
        
        try await contextQueue.perform {
            do {
                let MOs = try contextQueue.fetch(fetchRequest)
                
                for MO in MOs {
                    contextQueue.delete(MO)
                }
                
                try contextQueue.save()
                
                print("CLIENT \(Date.now) -- DataPC.fetchDeleteMOs: SUCCESS (entity: \(entityName)) (deleted: \(MOs.count))")
            } catch {
                print("CLIENT \(Date.now) -- DataPC.fetchDeleteMOs: FAILED (entity: \(entityName)) (\(error))")
                throw PError.failed
            }
        }
    }
    
    public func fetchDeleteMO<T1: NSManagedObject,
                              T2: CVarArg>(entity: T1.Type,
                                           queue: String = "background",
                                           predicateProperty: String? = nil,
                                           predicateValue: T2? = "",
                                           customPredicate: NSPredicate? = nil,
                                           completion: @escaping (Result<Void, PError>)->()) {
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
        
        contextQueue.perform {
            do {
                let MOs = try contextQueue.fetch(fetchRequest)
                
                if MOs.count > 1 { throw PError.multipleRecords }
                guard let MO = MOs.first else { throw PError.noRecordExists }
                
                contextQueue.delete(MO)
                
                try contextQueue.save()
                
                print("CLIENT \(Date.now) -- DataPC.fetchDeleteMO: SUCCESS (entity: \(entityName))")
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                print("CLIENT \(Date.now) -- DataPC.fetchDeleteMO: FAILED (entity: \(entityName)) (\(error))")
                
                DispatchQueue.main.async {
                    completion(.failure(error as? PError ?? .failed))
                }
            }
        }
    }
    
    public func fetchDeleteMOs<T1: NSManagedObject,
                               T2: CVarArg>(entity: T1.Type,
                                            queue: String = "background",
                                            predicateProperty: String? = nil,
                                            predicateValue: T2? = "",
                                            customPredicate: NSPredicate? = nil,
                                            completion: @escaping (Result<Void, PError>)->()) {
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
        
        contextQueue.perform {
            do {
                let MOs = try contextQueue.fetch(fetchRequest)
                
                for MO in MOs {
                    contextQueue.delete(MO)
                }
                
                try contextQueue.save()
                
                print("CLIENT \(Date.now) -- DataPC.fetchDeleteMOs: SUCCESS (entity: \(entityName)) (deleted: \(MOs.count))")
                
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                print("CLIENT \(Date.now) -- DataPC.fetchDeleteMOs: FAILED (entity: \(entityName)) (\(error))")
                
                DispatchQueue.main.async {
                    completion(.failure(error as? PError ?? .failed))
                }
            }
        }
    }
}
