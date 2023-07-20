//
//  MessageDC+Local.swift
//  bluezebra
//
//  Created by Harshel Bahl on 22/04/2023.
//

import Foundation

extension MessageDC {
    
    /// Local Read/Write Functions
    ///
    func syncMessageDC() async throws {
        try await syncChannel(channelID: "personal")
        
        for channel in ChannelDC.shared.channels {
            try await self.syncChannel(channelID: channel.channelID)
        }
    }
    
    func syncChannel(channelID: String,
                     fetchLimit: Int = 15,
                     sortKey: String = "date",
                     sortAscending: Bool = false) async throws {
        
        if channelID == "personal" {
            let SMOs = try await self.fetchMessages()
            
            DispatchQueue.main.async {
                self.personalMessages = SMOs
            }
        } else {
            let SMOs = try await fetchMessages(channelID: channelID)
            
            DispatchQueue.main.async {
                self.channelMessages[channelID] = SMOs
            }
        }
    }
    
    func addMessages(channelID: String,
                     fetchLimit: Int = 25,
                     sortKey: String = "date",
                     sortAscending: Bool = false) async throws {
        
        let earliestSMO = self.channelMessages[channelID]?.last
        
        if let earliestSMO = earliestSMO {
            let predicate = NSPredicate(format: "date < %@", argumentArray: [earliestSMO.date])
            
            let SMOs = try await DataPC.shared.fetchSMOsAsync(entity: Message.self,
                                                              customPredicate: predicate,
                                                              fetchLimit: fetchLimit,
                                                              sortKey: sortKey,
                                                              sortAscending: sortAscending)
            DispatchQueue.main.async {
                self.channelMessages[channelID]?.append(contentsOf: SMOs)
            }
        }
    }
    
    func createMessage(channelID: String = "personal",
                       message: String,
                       type: String,
                       date: Date) async throws -> SMessage {
        let sMO = try await DataPC.shared.createMessage(channelID: channelID,
                                                        userID: UserDC.shared.userData!.userID,
                                                        type: type,
                                                        date: date,
                                                        message: message,
                                                        isSender: true,
                                                        sent: nil,
                                                        delivered: nil,
                                                        read: nil,
                                                        remoteDeleted: nil)
        return sMO
    }
    
    func fetchMessages(channelID: String = "personal",
                       fetchLimit: Int = 15,
                       sortKey: String = "date",
                       sortAscending: Bool = false) async throws -> [SMessage] {
        let sMOs = try await DataPC.shared.fetchSMOsAsync(entity: Message.self,
                                                          predicateProperty: "channelID",
                                                          predicateValue: channelID,
                                                          fetchLimit: fetchLimit,
                                                          sortKey: sortKey,
                                                          sortAscending: sortAscending)
        return sMOs
    }
    
    func deleteMessage(messageID: String) async throws {
        try await DataPC.shared.fetchDeleteMOAsync(entity: Message.self,
                                                   predicateProperty: "messageID",
                                                   predicateValue: messageID)
    }
    
    func deleteChannelMessages(channelID: String) async throws {
        try await DataPC.shared.fetchDeleteMOsAsync(entity: Message.self,
                                                    predicateProperty: "channelID",
                                                    predicateValue: channelID)
    }
}
