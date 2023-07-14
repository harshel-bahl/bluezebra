//
//  ChannelDCEventQueue.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 15/03/2023.
//

import Foundation

class ChannelDCEventQueue {
    
    var eventQueue = [String:(Any?)->()]()

    func addEvent(eventName: String, event: @escaping (Any?)->()) {
        eventQueue[eventName] = event
    }
    
    // create function to remove events based on uuids
    
}
