//
//  MessageContainer.swift
//  bluezebra
//
//  Created by Harshel Bahl on 07/04/2023.
//

import SwiftUI

struct MessageContainer: View {
    
    @ObservedObject var userDC = UserDC.shared
    
    @EnvironmentObject var styles: Styles
    
    let channel: SChannel
    let message: SMessage
    
    @ViewBuilder func messageContainer() -> some View {
        switch message.type {
        case "text":
            TextContainer(channel: channel,
                          message: message,
                          containerStyle: (message.isSender ? styles.outgoingTextContainer : styles.incomingTextContainer))
        default:
            Color.clear
        }
    }
    
    var body: some View {
        messageContainer()
    }
}


