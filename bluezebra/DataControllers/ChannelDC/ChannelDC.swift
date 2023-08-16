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
    @Published var RUChannels = [SChannel]() {
        didSet {
            for channel in RUChannels {
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
    
}
