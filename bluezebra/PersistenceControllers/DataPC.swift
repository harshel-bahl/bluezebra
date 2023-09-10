//
//  DataPC.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 06/01/2023.
//

import CoreData

class DataPC: ObservableObject {
    
    static let shared = DataPC()
    
    var container: NSPersistentContainer
    
    var mainContext: NSManagedObjectContext
    var backgroundContext: NSManagedObjectContext
    
    init() {
        self.container = NSPersistentContainer(name: "Data")
        
        self.container.loadPersistentStores { description, error in
            if let error = error {
                log.error(message: "DataPC failed to load persistent stores", function: "DataPC.loadPersistentStores", error: error)
            } else {
                log.debug(message: "DataPC loaded persistent stores", function: "DataPC.loadPersistentStores", info: description.description)
            }
        }
        
        self.mainContext = self.container.viewContext
        self.backgroundContext = self.container.newBackgroundContext()
    }
    
    /// Save Functions
    ///
    func mainSave() throws {
        if self.mainContext.hasChanges {
            try self.mainContext.save()
        }
    }
    
    func backgroundSave() throws {
        if self.backgroundContext.hasChanges {
            try self.backgroundContext.save()
        }
    }
    
    /// Scheduling Functions
    ///
    func mainPerformSync<T>(
        saveOnComplete: Bool = true,
        rollbackOnErr: Bool = true,
        oper: () throws -> T
    ) async throws -> T {
        return try await withCheckedThrowingContinuation() { continuation in
            do {
                let result = try self.mainContext.performAndWait() {
                    let result = try oper()
                    
                    if saveOnComplete { try self.mainSave() }
                    
                    return result
                }
                
                log.debug(message: "successfully saved main context", function: "DataPC.mainPerformSync")
                
                continuation.resume(returning: result)
            } catch {
                log.error(message: "failed to save main context", function: "DataPC.mainPerformSync", error: error)
                
                if rollbackOnErr { self.mainContext.rollback() }
                
                continuation.resume(throwing: error)
            }
        }
    }

    func mainPerformAsync<T>(
        saveOnComplete: Bool = true,
        rollbackOnErr: Bool = true,
        oper: @escaping () throws -> T
    ) async throws -> T {
        do {
            let result = try await self.mainContext.perform {
                let result = try oper()
                
                if saveOnComplete { try self.mainSave() }
                
                return result
            }
            
            log.debug(message: "successfully saved main context", function: "DataPC.mainPerformAsync")
            
            return result
        } catch {
            log.error(message: "failed to save main context", function: "DataPC.mainPerformAsync", error: error)
            
            if rollbackOnErr { self.mainContext.rollback() }
            
            throw error
        }
    }

    func backgroundPerformSync<T>(
        saveOnComplete: Bool = true,
        rollbackOnErr: Bool = true,
        oper: () throws -> T
    ) async throws -> T {
        return try await withCheckedThrowingContinuation() { continuation in
            do {
                let result = try self.backgroundContext.performAndWait {
                    let result = try oper()
                    
                    if saveOnComplete { try self.backgroundSave() }
                    
                    return result
                }
                
                log.debug(message: "successfully saved background context", function: "DataPC.backgroundPerformSync")
                
                continuation.resume(returning: result)
            } catch {
                log.error(message: "failed to save background context", function: "DataPC.backgroundPerformSync", error: error)
                
                if rollbackOnErr { self.backgroundContext.rollback() }
                
                continuation.resume(throwing: error)
            }
        }
    }
    
    func backgroundPerformAsync<T>(
        saveOnComplete: Bool = true,
        rollbackOnErr: Bool = true,
        oper: @escaping () throws -> T
    ) async throws -> T {
        do {
            let result = try await self.backgroundContext.perform {
                let result = try oper()
                
                if saveOnComplete { try self.backgroundSave() }
                
                return result
            }
            
            log.debug(message: "successfully saved background context", function: "DataPC.backgroundPerformAsync")
            
            return result
        } catch {
            log.error(message: "failed to save background context", function: "DataPC.backgroundPerformAsync", error: error)
            
            if rollbackOnErr { self.backgroundContext.rollback() }
            
            throw error
            
        }
    }
    
    func getObjectIDs<T: NSManagedObject>(
        objects: [T]
    ) -> [NSManagedObjectID] {
       
        let objectIDs = objects.map { $0.objectID }
        
        return objectIDs
    }
    
//    func checkObjects() async throws {
//
//        let
//    }
}


protocol ToSafeObject {
    associatedtype SafeType
    func safeObject() throws -> SafeType
}

