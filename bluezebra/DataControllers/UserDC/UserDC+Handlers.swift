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
            
            log.info(message: "receivedPendingEvents triggered", event: "UserDC.receivedPendingEvents")
            
            self?.syncReceivedPendingEvents(result: true)
            
            log.info(message: "handled received pending events successfully", event: "UserDC.receivedPendingEvents")
            
            ack.with(NSNull())
        }
    }
}
