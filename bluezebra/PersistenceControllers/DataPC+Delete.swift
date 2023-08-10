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
    public func fetchDeleteMO<T1: NSManagedObject,
                                   T2: CVarArg>(entity: T1.Type,
                                                queue: String = "background",
                                                predicateProperty: String? = nil,
                                                predicateValue: T2? = "",
                                                customPredicate: NSPredicate? = nil,
                                                showLogs: Bool = false) async throws {
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
            try await contextQueue.perform {
                
                let MOs = try contextQueue.fetch(fetchRequest)
                
                if MOs.count > 1 { throw PError.multipleRecords(func: "fetchDeleteMO", err: "entity: \(String(describing: entity))") }
                guard let MO = MOs.first else { throw PError.noRecordExists(func: "fetchDeleteMO", err: "entity: \(String(describing: entity))") }
                
                contextQueue.delete(MO)
                
                try contextQueue.save()
                
                if showLogs { print("SUCCESS \(DateU.shared.logTS) -- DataPC.fetchDeleteMO entity: \(entityName)") }
            }
        } catch {
            if let error = error as? PError {
                throw error
            } else {
                throw PError.persistenceError(func: "DataPC.fetchDeleteMO", err: error.localizedDescription)
            }
        }
    }
    
    public func fetchDeleteMOs<T1: NSManagedObject,
                                    T2: CVarArg>(entity: T1.Type,
                                                 queue: String = "background",
                                                 predicateProperty: String? = nil,
                                                 predicateValue: T2? = "",
                                                 customPredicate: NSPredicate? = nil,
                                                 showLogs: Bool = false) async throws {
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
            try await contextQueue.perform {
                let MOs = try contextQueue.fetch(fetchRequest)
                
                for MO in MOs {
                    contextQueue.delete(MO)
                }
                
                try contextQueue.save()
                
                if showLogs { print("SUCCESS \(DateU.shared.logTS) -- DataPC.fetchDeleteMOs entity: \(entityName), deleted: \(MOs.count)") }
            }
        } catch {
            if let error = error as? PError {
                throw error
            } else {
                throw PError.persistenceError(func: "DataPC.fetchDeleteMOs", err: error.localizedDescription)
            }
        }
    }
}
