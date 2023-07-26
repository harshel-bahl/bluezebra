//
//  MessageDC+Local.swift
//  bluezebra
//
//  Created by Harshel Bahl on 22/04/2023.
//

import Foundation
import SwiftUI

extension MessageDC {
    
    /// Local Setup Functions
    ///
    func checkAndCreateDirs(dirs: [String] = ["images", "files"]) throws {
        for dir in dirs {
            let dirCheck = DataPC.shared.checkDir(dir: dir)
            
            if !dirCheck {
                print("CLIENT \(DateU.shared.logTS) -- MessageDC.checkAndCreateDirs: Directory not found (\(dir))")
                try DataPC.shared.createDir(dir: dir)
            }
        }
    }
    
    /// Local Sync Functions
    ///
    func syncMessageDC() async throws {
        
        try await self.syncChannel()
        
        for channel in ChannelDC.shared.channels {
            try await self.syncChannel(channelID: channel.channelID)
        }
    }
    
    func syncChannel(channelID: String = "personal",
                     fetchLimit: Int = 10,
                     sortKey: String = "date",
                     sortAscending: Bool = false) async throws {
        let SMOs = try await fetchMessages(channelID: channelID,
                                           fetchLimit: fetchLimit,
                                           sortKey: sortKey,
                                           sortAscending: sortAscending)
        
        DispatchQueue.main.async {
            self.channelMessages[channelID] = SMOs
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
    
    /// Local Create Functions
    ///
    func createTextMessage(channelID: String = "personal",
                           userID: String = UserDC.shared.userData!.userID,
                           type: String = MessageType.text.rawValue,
                           date: Date = DateU.shared.currDT,
                           isSender: Bool = true,
                           message: String) async throws -> SMessage {
        
        let SMO = try await DataPC.shared.createMessage(channelID: channelID,
                                                        userID: userID,
                                                        type: type,
                                                        date: date,
                                                        isSender: isSender,
                                                        message: message)
        return SMO
    }
    
    func createImageMessage(channelID: String = "personal",
                            userID: String = UserDC.shared.userData!.userID,
                            type: String = MessageType.image.rawValue,
                            date: Date = DateU.shared.currDT,
                            isSender: Bool = true,
                            message: String,
                            selectedImages: [IdentifiableImage],
                            fileType: String = ".jpg") async throws -> SMessage {
        
        var resourceIDs = [String]()
        
        for iImage in selectedImages {
            let resourceID = iImage.id.uuidString + fileType
            
            resourceIDs.append(resourceID)
            
            try await self.storeImage(image: iImage.image,
                                name: resourceID)
        }
        
        let SMO = try await DataPC.shared.createMessage(channelID: channelID,
                                                        userID: userID,
                                                        type: type,
                                                        date: date,
                                                        isSender: isSender,
                                                        message: message,
                                                        resourceIDs: resourceIDs)
        
        return SMO
    }
    
//    func createFileMessage(channelID: String = "personal",
//                           userID: String = UserDC.shared.userData!.userID,
//                           type: MessageType.file.rawValue,
//                           date: Date = DateU.shared.currDT,
//                           isSender: Bool = true,
//                           message: String,
//                           resourceIDs: [String]? = nil) async throws -> SMessage {
//
//    }
    
    /// SMO Sync Functions
    ///
    func addChannel(channelID: String) {
        DispatchQueue.main.async {
            if !self.channelMessages.keys.contains(channelID) {
                self.channelMessages[channelID] = [SMessage]()
            }
        }
    }
    
    func addMessage(channelID: String,
                    message: SMessage) {
        DispatchQueue.main.async {
            if self.channelMessages.keys.contains(channelID) {
                self.channelMessages[channelID]?.insert(message, at: 0)
            } else {
                self.channelMessages[channelID] = [message]
            }
        }
    }
    
    /// Local Data Functions
    ///
    func storeImage(image: UIImage,
                    name: String = UUID().uuidString,
                    compressionQuality: Double = 0.8) async throws {
        
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            throw DCError.imageDataFailure
        }
        
        try await DataPC.shared.storeFile(data: imageData,
                                    name: name,
                                    dir: "images")
    }
    
    func fetchImage(imageName: String) async throws -> UIImage {
        let imageData = try await DataPC.shared.fetchFile(fileName: imageName,
                                                    dir: "images")
        
        guard let uiImage = UIImage(data: imageData) else {
            throw DCError.imageDataFailure
        }
        
        return uiImage
    }
    
    /// Local Fetch Functions
    ///
    func fetchMessages(channelID: String = "personal",
                       fetchLimit: Int = 15,
                       sortKey: String = "date",
                       sortAscending: Bool = false) async throws -> [SMessage] {
        let SMOs = try await DataPC.shared.fetchSMOsAsync(entity: Message.self,
                                                          predicateProperty: "channelID",
                                                          predicateValue: channelID,
                                                          fetchLimit: fetchLimit,
                                                          sortKey: sortKey,
                                                          sortAscending: sortAscending)
        return SMOs
    }
    
    /// Local Remove Functions
    ///
    func removeMessage(channelID: String,
                       messageID: String) {
        DispatchQueue.main.async {
            let messageIndex = self.channelMessages[channelID]?.firstIndex(where: { $0.messageID == messageID })
            if let messageIndex = messageIndex {
                self.channelMessages[channelID]?.remove(at: messageIndex)
            }
        }
    }
    
    func removeChannelMessages(channelID: String) {
        DispatchQueue.main.async {
            if self.channelMessages.keys.contains(channelID) {
                self.channelMessages[channelID] = [SMessage]()
            }
        }
    }
    
    func removeChannel(channelID: String) {
        DispatchQueue.main.async {
            if self.channelMessages.keys.contains(channelID) {
                self.channelMessages.removeValue(forKey: channelID)
            }
        }
    }
    
    /// Local Delete Functions
    ///
    func deleteMessage(channelID: String,
                       messageID: String) async throws {
        
        self.removeMessage(channelID: channelID,
                           messageID: messageID)
        
        try await DataPC.shared.fetchDeleteMOAsync(entity: Message.self,
                                                   predicateProperty: "messageID",
                                                   predicateValue: messageID)
    }
    
    func clearChannelMessages(channelID: String) async throws {
        
        self.removeChannelMessages(channelID: channelID)
        
        try await DataPC.shared.fetchDeleteMOsAsync(entity: Message.self,
                                                    predicateProperty: "channelID",
                                                    predicateValue: channelID)
    }
    
    func deleteChannelMessages(channelID: String) async throws {
        
        self.removeChannel(channelID: channelID)
        
        try await DataPC.shared.fetchDeleteMOsAsync(entity: Message.self,
                                                    predicateProperty: "channelID",
                                                    predicateValue: channelID)
    }
    
    
}
