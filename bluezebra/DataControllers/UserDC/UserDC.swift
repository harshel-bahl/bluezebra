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
    
    @Published var userData: SUser?
    @Published var userSettings: SSettings?
    
    /// loggedIn: controls whether user has authenticated into app
    @Published var loggedIn = false {
        didSet {
#if DEBUG
            DataU.shared.handleSuccess(info: "UserDC.loggedIn: \(loggedIn)")
#endif
        }
    }
    
    /// userOnline: state of user connection to server
    @Published var userOnline: Bool = false {
        didSet {
#if DEBUG
            DataU.shared.handleSuccess(info: "UserDC.userOnline: \(userOnline)")
#endif
        }
    }
    
    @Published var emittedPendingEvents: Bool = false {
        didSet {
#if DEBUG
            DataU.shared.handleSuccess(info: "UserDC.emittedPendingEvents: \(emittedPendingEvents)")
#endif
        }
    }
    
    init() {
        self.addSocketHandlers()
    }
}

