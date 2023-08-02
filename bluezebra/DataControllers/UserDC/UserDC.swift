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
    @Published var loggedIn = false
    
    /// userOnline: state of user connection to server
    @Published var userOnline: Bool = false {
        didSet {
            print("CLIENT \(DateU.shared.logTS) -- UserDC.userOnline: \(userOnline)")
        }
    }
    
    init() {
        self.addSocketHandlers()
    }
    
    /// Reset User Data Controller Functions
    ///
    func resetState() {
        DispatchQueue.main.async {
            if self.userData != nil { self.userData = nil }
            if self.userSettings != nil { self.userSettings = nil }
            if self.loggedIn != false { self.loggedIn = false }
            if self.userOnline != false { self.userOnline = false }
            
            print("CLIENT \(DateU.shared.logTS) -- UserDC.resetState: SUCCESS")
        }
    }
}

