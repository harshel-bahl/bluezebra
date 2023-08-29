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
    
    @Published var personalChannel: SChannel? {
        didSet {
            if let personalChannel = personalChannel,
               !MessageDC.shared.channelMessages.keys.contains(personalChannel.channelID) {
                MessageDC.shared.channelMessages[personalChannel.channelID] = [SMessage]()
            }
        }
    }
    
    /// channels: channels with a single remote user
    /// - uses an array since it is fetched in order of lastMessageDate
    /// - only contains active=true objects
    @Published var RUChannels = [SChannel]() {
        didSet {
            for channel in RUChannels {
                let channelID = channel.channelID
                
                if !MessageDC.shared.channelMessages.keys.contains(channelID) {
                    MessageDC.shared.channelMessages[channelID] = [SMessage]()
                }
                
                let userID = channel.userID
                
                if !self.RUs.keys.contains(userID) {
                    Task {
                        if let SRU = try? await self.fetchRUOffOn(userID: userID) {
                            self.syncRU(RU: SRU)
                        }
                    }
                }
            }
        }
    }
    
    /// onlineUsers: [userID: online true/false]
    @Published var onlineUsers = [String: Bool]()

    /// channelRequests:
    /// - uses an array since it is fetched in order of date
    @Published var CRs = [SChannelRequest]() {
        didSet {
            for CR in CRs {
                let userID = CR.userID
                
                if !self.RUs.keys.contains(userID) {
                    Task {
                        if let SRU = try? await self.fetchRUOffOn(userID: userID) {
                            self.syncRU(RU: SRU)
                        }
                    }
                }
            }
        }
    }
    
    /// channelDeletions:
    /// - uses an array since it is fetched in order of deletionDate
    @Published var CDs = [SChannelDeletion]()
    
    /// RUs
    /// - array is updated to sync with RUChannels and CRs
    @Published var RUs = [String: SRemoteUser]()
    
    /// serverRUChannelSync
    /// - checks RUChannel exists with server
    /// - checks RU exists for RUChannel in server
    @Published var serverRUChannelSync = false
    
    /// serverCRSync
    /// - checks CR exists in server
    /// - checks RU exists for CR in server
    @Published var serverCRSync = false
    
    
    init() {
        self.addSocketHandlers()
    }
    
}
