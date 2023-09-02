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
    internal func mainSave() throws {
        do {
            if self.mainContext.hasChanges {
                try self.mainContext.save()
            }
        } catch {
            throw PError.persistenceError(err: error.localizedDescription)
        }
    }
    
    internal func backgroundSave() throws {
        do {
            if self.backgroundContext.hasChanges {
                try self.backgroundContext.save()
            }
        } catch {
            throw PError.persistenceError(err: error.localizedDescription)
        }
    }
    
    /// Scheduling Functions
    ///
    internal func performOnMain(
}


protocol ToSafeObject {
    associatedtype SafeType
    func safeObject() throws -> SafeType
}

