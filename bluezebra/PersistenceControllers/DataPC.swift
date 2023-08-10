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
                fatalError("Error: \(error.localizedDescription)")
            }
        }
        
        self.mainContext = self.container.viewContext
        self.backgroundContext = self.container.newBackgroundContext()
    }
    
    /// Helper Functions
    ///
    internal func mainSave() throws {
        do {
            if self.mainContext.hasChanges {
                try self.mainContext.save()
            }
        } catch {
            throw PError.persistenceError(func: "DataPC.mainSave", err: error.localizedDescription)
        }
    }
    
    internal func backgroundSave() throws {
        do {
            if self.backgroundContext.hasChanges {
                try self.backgroundContext.save()
            }
        } catch {
            throw PError.persistenceError(func: "DataPC.backgroundSave", err: error.localizedDescription)
        }
    }
}


protocol ToSafeObject {
    associatedtype SafeType
    func safeObject() throws -> SafeType
}

