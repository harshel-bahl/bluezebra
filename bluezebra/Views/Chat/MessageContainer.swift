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
        if message.localDeleted == true {
            DeletedContainer(message: message)
        } else if message.imageIDs != nil {
            ImageContainer(message: message)
        } else if message.message != nil {
            TextContainer(message: message)
        }
    }
}
