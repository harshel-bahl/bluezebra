//
//  MessageDC.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 12/01/2023.
//

import SwiftUI
import CoreData
import SocketIO

class MessageDC: ObservableObject {
    
    static let shared = MessageDC()
    
    /// channelMessages: [channelID: Messages]
    /// First message is the latest message
    @Published var channelMessages = [UUID: [SMessage]]()
    
    @Published var unreadChannels: Int?
    
    init() {
        self.addSocketHandlers()
    }
    
    /// MessageDC reset function
    ///
    func resetState() {
        DispatchQueue.main.async {
            self.channelMessages = [UUID: [SMessage]]()
            self.unreadChannels = nil
            
        }
    }
}

enum MessageType: String {
    case text = "text" 
    case image = "image"
    case file = "file"
}
