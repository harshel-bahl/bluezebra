//
//  DataPersistenceController.swift
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
    
    enum PError: Error {
        case failed
        case recordExists
        case noRecordExists
        case multipleRecords
        case typecastError
        case safeMapError
    }
    
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
        if self.mainContext.hasChanges {
            try self.mainContext.save()
        }
    }
    
    internal func backgroundSave() throws {
        if self.backgroundContext.hasChanges {
            try self.backgroundContext.save()
        }
    }
}


protocol ToSafeObject {
    associatedtype SafeType
    func safeObject() throws -> SafeType
}

