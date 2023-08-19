//
//  UserDC+Handlers.swift
//  bluezebra
//
//  Created by Harshel Bahl on 19/04/2023.
//

import Foundation

extension UserDC {
    
    /// Socket Handlers
    ///
    func addSocketHandlers() {
        receivedPendingEventsNotif()
    }
    
    func receivedPendingEventsNotif() {
        SocketController.shared.clientSocket.on("receivedPendingEvents") { [weak self] (data, ack) in
#if DEBUG
            DataU.shared.handleEventTrigger(eventName: "ChannelDC.receivedPendingEvents")
#endif
            guard let self = self else { return }
            
            self.emittedPendingEvents = true
            
            ack.with(NSNull())
            
#if DEBUG
            DataU.shared.handleEventSuccess(eventName: "ChannelDC.receivedPendingEvents")
#endif
        }
    }
}
