//
//  MessageContainer.swift
//  bluezebra
//
//  Created by Harshel Bahl on 15/07/2023.
//

import SwiftUI

struct MessageContainer: View {
    
    @EnvironmentObject var chatState: ChatState
    
    let message: SMessage
    let messageStatus: String?
    
    init(message: SMessage,
         messageStatus: String? = nil) {
        self.message = message
        self.messageStatus = messageStatus
    }
    var body: some View {
        messageContainer(message: self.message)
    }
    
    @ViewBuilder func messageContainer(message: SMessage) -> some View {
        switch message.type {
        case "text":
            TextContainer(message: message,
                          showReceipt: messageStatus != nil ? true : false,
                          messageStatus: messageStatus)
        case "image":
            ImageContainer()
        default:
            Color.clear
        }
    }
}
