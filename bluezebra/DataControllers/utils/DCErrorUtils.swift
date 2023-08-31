//
//  DCErrorUtilities.swift
//  bluezebra
//
//  Created by Harshel Bahl on 30/08/2023.
//

import Foundation


func checkSocketConnected() throws {
    
    guard SocketController.shared.connected else { throw DCError.socketDisconnected() }
    
}

func checkUserConnected() throws {
    
    guard UserDC.shared.userConnected else { throw DCError.userDisconnected() }
    
}

func checkReceivedPendingEvents() throws {
    
    guard UserDC.shared.receivedPendingEvents else { throw DCError.receivedPendingEventsFailure() }
    
}
