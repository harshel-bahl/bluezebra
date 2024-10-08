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
    @Published var images = [String: Data]()
    
    init(currChannel: SChannel,
         currRU: SRemoteUser? = nil) {
        self.currChannel = currChannel
        self.currRU = currRU
    }
    
    func computeReceipt(message: SMessage) -> String? {
        if currChannel.channelType == "personal" {
            return nil
        } else if !message.isSender {
            return nil
        } else {
            if let readUsers = message.read?.components(separatedBy: ","),
               self.currChannel.uID.uuidString == readUsers[0] {
                return "read"
            } else if let deliveredUsers = message.delivered?.components(separatedBy: ","),
                      self.currChannel.uID.uuidString == deliveredUsers[0] {
                return "delivered"
            } else if let sentUsers = message.sent?.components(separatedBy: ","),
                      sentUsers[0] == self.currChannel.uID.uuidString {
                return "sent"
            } else {
                return "notSent"
            }
        }
    }
    
    func fetchImages() async throws {
        guard let messages = MessageDC.shared.channelMessages[currChannel.channelID] else { return }
        
        for message in messages {
            if let imageID = message.imageIDs?.components(separatedBy: ",")[0],
               images[imageID] == nil {
//                let imageData = try? await DataPC.shared.fetchFile(fileName: resourceID,
//                                                                   dir: "images")
//
//                DispatchQueue.main.async {
//                    self.images[resourceID] = imageData
//                }
            }
        }
    }
}
