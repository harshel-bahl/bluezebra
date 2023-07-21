//
//  ChatState.swift
//  bluezebra
//
//  Created by Harshel Bahl on 18/07/2023.
//

import Foundation
import SwiftUI

class ChatState: ObservableObject {
    
    @Published var currChannel: SChannel
    @Published var currRU: SRemoteUser?
    
    init(currChannel: SChannel,
         currRU: SRemoteUser? = nil) {
        self.currChannel = currChannel
        self.currRU = currRU
    }
    
    func computeReceipt(message: SMessage) -> String? {
        if currChannel.channelID == "personal" {
            return nil
        } else if !message.isSender {
            return nil
        } else {
            if let readUsers = message.read?.components(separatedBy: ","),
               self.currChannel.userID == readUsers[0] {
                return "read"
            } else if let deliveredUsers = message.delivered?.components(separatedBy: ","),
                      self.currChannel.userID == deliveredUsers[0] {
                return "delivered"
            } else if let sentUsers = message.sent?.components(separatedBy: ","),
                      sentUsers[0] == self.currChannel.userID {
                return "sent"
            } else {
                return "notSent"
            }
        }
    }
}
