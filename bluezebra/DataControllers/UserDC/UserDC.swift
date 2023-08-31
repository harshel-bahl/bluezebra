//
//  UserDC.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 05/01/2023.
//

import Combine
import CoreData
import SocketIO

class UserDC: ObservableObject {
    
    static let shared = UserDC()
    
    @Published var userdata: SUser?
    @Published var userSettings: SSettings?
    
    /// loggedIn: controls whether user has authenticated into app
    @Published var loggedIn = false {
        didSet {
            log.info(message: "user is logged in", info: "UserDC.loggedIn: \(loggedIn)")
        }
    }
    
    /// userConnected
    /// - whether user is authenticated and connected to server
    @Published var userConnected: Bool = false {
        didSet {
            log.info(message: "user is connected", info: "UserDC.userConnected: \(userConnected)")
        }
    }
    
    // receivedPendingEvents
    // - whether user has received server's pending events
    @Published var receivedPendingEvents: Bool = false {
        didSet {
            log.info(message: "user received pending events", info: "UserDC.receivedPendingEvents: \(receivedPendingEvents)")
        }
    }
    
    init() {
        self.addSocketHandlers()
    }
}

