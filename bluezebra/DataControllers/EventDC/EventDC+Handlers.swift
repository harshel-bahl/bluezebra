//
//  EventDC+Handlers.swift
//  bluezebra
//
//  Created by Harshel Bahl on 9/13/23.
//

import Foundation
import SocketIO

extension EventDC {
    
    func addSocketHandlers() {
        self.receivedEvent()
        self.receivedEventBatch()
    }
    
    func receivedEvent() {
        SocketController.shared.clientSocket.on("receivedEvent") { (data, ack) in
            
            log.debug(message: "event triggered", event: "receivedEvent")
            
            Task {
                do {
                    guard let data = data.first as? Data else { throw DCError.typecastError(err: "failed to typecast data to Data") }
                    
                    let event = try DataU.shared.jsonDecodeFromData(packet: EventP.self,
                                                                    data: data)
                    
//                    try await self.funnelEvent(eventID: event.eventID, eventName: event.eventName, data: event.packet)
                    
                    ack.with(NSNull())
                    
                    log.info(message: "successfully handled event", event: "receivedEvent", info: "eventName: \(event.eventName)")
                } catch {
                    ack.with(false)
                    log.error(message: "failed to handle event", event: "receivedEvent", error: error)
                }
            }
        }
    }
    
    func receivedEventBatch() {
        SocketController.shared.clientSocket.on("receivedEventBatch") { (data, ack) in
            
            log.debug(message: "event triggered", event: "receivedEventBatch")
            
            Task {
                do {
                    guard let data = data.first as? Data else { throw DCError.typecastError(err: "failed to typecast data to Data") }
                    
                    let eventBatch = try DataU.shared.jsonDecodeFromData(packet: [EventP].self,
                                                                         data: data)
                    
                    var returnBatch: [String: Bool] = [:]
                    
                    for event in eventBatch {
                        do {
                            guard let eventID = event.eventID else { throw DCError.nilError(err: "eventID is missing") }
                            
                            do {
//                                try await self.funnelEvent(eventID: eventID, eventName: event.eventName, data: event.packet as Any)
                                
                                returnBatch[eventID] = true
                                log.info(message: "successfully handed event", function: "EventDC.receivedEventBatch", event: event.eventName)
                            } catch {
                                returnBatch[eventID] = false
                                log.error(message: "failed to handle event", function: "EventDC.receivedEventBatch", event: event.eventName, error: error)
                            }
                        } catch {
                            log.error(message: "failed to handle event", function: "EventDC.receivedEventBatch", event: event.eventName, error: error)
                        }
                    }
                    
                    ack.with(NSNull(), returnBatch)
                    
                    log.info(message: "successfully handled event batch", event: "receivedEventBatch", info: "recBatch: \(eventBatch.count), returnBatch: \(returnBatch.keys.count)")
                    
                } catch {
                    ack.with(String(describing: error))
                    log.error(message: "failed to handle event batch", event: "receivedEventBatch", error: error)
                }
            }
        }
    }
    
//    func funnelEvent(
//        eventID: String? = nil,
//        eventName: String,
//        data: Any? = nil
//    ) async throws {
//
//        switch eventName {
//
//            /// ChannelDC Handlers
//            ///
//        case "userOnline":
//            ChannelDC.shared.userOnline(data: data as Any)
//        case "userDisconnected":
//            ChannelDC.shared.userDisconnected(data: data as Any)
//        case "receivedCR":
//            ChannelDC.shared.receivedCR(data: data as Any)
//        case "receivedCRResult":
//            ChannelDC.shared.receivedCRResult(data: data as Any)
//        case "receivedCD":
//            ChannelDC.shared.receivedCD(data: data as Any)
//        case "receivedCDResult":
//            ChannelDC.shared.receivedCDResult(data: data as Any)
//        case "deleteUserTrace":
//            ChannelDC.shared.deleteUserTrace(data: data as Any)
//
//            /// MessageDC Handlers
//            ///
//        case "receivedMessage":
//            MessageDC.shared.receivedMessage(data: data as Any)
//        case "receivedMD":
//            MessageDC.shared.receivedMD(data: data as Any)
//        case "receivedMDResult":
//            MessageDC.shared.receivedMDResult(data: data as Any)
//        case "deliveredMessage":
//            MessageDC.shared.deliveredMessage(data: data as Any)
//        case "readMessage":
//            MessageDC.shared.readMessage(data: data as Any)
//
//        default: break
//        }
//    }
}
