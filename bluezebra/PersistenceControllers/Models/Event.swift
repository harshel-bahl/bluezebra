//
//  Event.swift
//  bluezebra
//
//  Created by Harshel Bahl on 06/08/2023.
//

import Foundation
import CoreData

struct SEvent {
    let eventID: String
    let eventName: String
    let date: Date
    let uID: String
    let attempts: Int16
    let packet: Data?
}

class Event: NSManagedObject {
    @NSManaged var eventID: String?
    @NSManaged var eventName: String?
    @NSManaged var date: Date?
    @NSManaged var uID: String?
    @NSManaged var attempts: Int16
    @NSManaged var packet: Data?
}

extension Event: ToSafeObject {
    
    func safeObject() throws -> SEvent {
        
        guard let eventID = self.eventID,
              let eventName = self.eventName,
              let date = self.date,
              let uID = self.uID else {
            throw PError.safeMapError()
        }
        
        return SEvent(eventID: eventID,
                      eventName: eventName,
                      date: date,
                      uID: uID,
                      attempts: self.attempts,
                      packet: self.packet)
    }
}
