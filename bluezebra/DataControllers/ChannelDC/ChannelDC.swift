//
//  ChannelDC.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 06/01/2023.
//

import SwiftUI
import CoreData
import SocketIO

class ChannelDC: ObservableObject {
    
    static let shared = ChannelDC()
    
    /// remoteUsers: [userID: RemoteUser]
    ///
    @Published var RUs = [String: SRemoteUser]() {
        didSet {
            for user in RUs.values {
                if !self.onlineUsers.keys.contains(user.userID) {
                    self.onlineUsers[user.userID] = false
                }
            }
        }
    }
    
    /// onlineUsers: [userID: online true/false]
    @Published var onlineUsers = [String: Bool]()
    
    /// channels: channels with a single remote user
    /// - uses an array since it is fetched in order of lastMessageDate
    /// - only contains active=true objects
    @Published var channels = [SChannel]() {
        didSet {
            for channel in channels {
                let channelID = channel.channelID
                
                if !MessageDC.shared.channelMessages.keys.contains(channelID) {
                    MessageDC.shared.channelMessages[channelID] = [SMessage]()
                }
            }
        }
    }
    
    @Published var personalChannel: SChannel? {
        didSet {
            if let personalChannel = personalChannel,
               !MessageDC.shared.channelMessages.keys.contains(personalChannel.channelID) {
                MessageDC.shared.channelMessages[personalChannel.channelID] = [SMessage]()
            }
        }
    }

    /// channelRequests:
    /// - uses an array since it is fetched in order of date
    @Published var CRs = [SChannelRequest]()
    
    /// channelDeletions:
    /// - uses an array since it is fetched in order of deletionDate
    @Published var CDs = [SChannelDeletion]()
    
    init() {
        self.addSocketHandlers()
    }
    
    func socketCallback<T>(data: [Any],
                           functionName: String,
                           failureCompletion: ((Result<T, DCError>)->())? = nil,
                           completion: @escaping (Any?) ->()) {
        do {
            if (data.first as? Bool)==true {
                print("SERVER \(DateU.shared.logTS) -- ChannelDC.\(functionName): SUCCESS")
                
                if data.count > 1 {
                    completion(data[1])
                } else {
                    completion(nil)
                }
            } else if (data.first as? Bool)==false {
                throw DCError.serverFailure
            } else if let result = data.first as? String, result==SocketAckStatus.noAck {
                throw DCError.timeOut
            } else {
                throw DCError.failed
            }
        } catch {
            print("SERVER \(DateU.shared.logTS) -- ChannelDC.\(functionName): FAILED (\(error))")
            
            if let failureCompletion = failureCompletion {
                failureCompletion(.failure(error as? DCError ?? .failed))
            }
        }
    }
    
    func jsonDecodeFromObject<T: Codable>(packet: T.Type,
                                          data: Any) throws -> T {
        guard let data = try? JSONSerialization.data(withJSONObject: data as Any, options: []) else { throw DCError.typecastError }
        let dataPacket = try JSONDecoder().decode(T.self, from: data)
        return dataPacket
    }
    
    func jsonDecodeFromData<T: Codable>(packet: T.Type,
                                        data: Any) throws -> T {
        
        guard let data = data as? Data else { throw DCError.typecastError }
        let dataPacket = try JSONDecoder().decode(T.self, from: data)
        return dataPacket
    }
    
    /// ChannelDC reset function
    ///
    func resetState() {
        DispatchQueue.main.async {
            self.RUs = [String: SRemoteUser]()
            self.onlineUsers = [String: Bool]()
            
            self.channels = [SChannel]()
            self.personalChannel = nil
            
            self.CRs = [SChannelRequest]()
            self.CDs = [SChannelDeletion]()
        }
    }
}
