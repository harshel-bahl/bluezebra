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
            
            log.info(message: "receivedPendingEvents triggered", event: "receivedPendingEvents")
            
            guard let self = self else { return }
            
            self.syncReceivedPendingEvents(result: true)
            
            ack.with(NSNull())
        }
    }
}
