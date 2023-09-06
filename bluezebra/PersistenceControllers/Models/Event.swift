//
//  Event.swift
//  bluezebra
//
//  Created by Harshel Bahl on 06/08/2023.
//

import Foundation
import CoreData

struct SEvent {
    let eventID: UUID
    let eventName: String
    let date: Date
    let recUID: UUID
    let packet: Data?
}

class Event: NSManagedObject {
    @NSManaged var eventID: UUID
    @NSManaged var eventName: String
    @NSManaged var date: Date
    @NSManaged var recUID: UUID
    @NSManaged var packet: Data?
}

extension Event: ToSafeObject {
    
    func safeObject() throws -> SEvent {
        return SEvent(eventID: self.eventID,
                      eventName: self.eventName,
                      date: self.date,
                      recUID: self.recUID,
                      packet: self.packet)
    }
}
