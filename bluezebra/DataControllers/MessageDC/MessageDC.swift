//
//  MessageDC.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 12/01/2023.
//

import SwiftUI
import CoreData
import SocketIO

class MessageDC: ObservableObject {
    
    static let shared = MessageDC()
    
    /// channelMessages: [channelID: Messages]
    /// First message is the latest message
    @Published var channelMessages = [String: [SMessage]]()
    
    @Published var unreadChannels: Int?
    
    init() {
        self.addSocketHandlers()
    }
    
    func socketCallback<T>(data: [Any],
                           functionName: String,
                           failureCompletion: ((Result<T, DCError>)->())? = nil,
                           completion: @escaping (Any?)->()) {
        DispatchQueue.main.async {
            do {
                if (data.first as? Bool)==true {
                    print("SERVER \(DateU.shared.logTS) -- MessageDC.\(functionName): SUCCESS")
                    
                    if data.count > 1 {
                        completion(data[1])
                    } else {
                        completion(nil)
                    }
                } else if let result = data.first as? String, result==SocketAckStatus.noAck {
                    throw DCError.timeOut
                } else {
                    throw DCError.failed
                }
            } catch {
                print("SERVER \(DateU.shared.logTS) -- MessageDC.\(functionName): FAILED (\(error))")
                if let failureCompletion = failureCompletion {
                    failureCompletion(.failure(error as? DCError ?? .failed))
                }
            }
        }
    }
    
    /// MessageDC reset function
    ///
    func resetState() {
        DispatchQueue.main.async {
            self.channelMessages = [String: [SMessage]]()
            self.unreadChannels = nil
            
            print("CLIENT \(DateU.shared.logTS) -- MessageDC.resetState: SUCCESS")
        }
    }
}

enum MessageType: String {
    case text = "text" // represents only text
    case image = "image"
    case file = "file"
}
