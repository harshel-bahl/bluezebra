//
//  MessageDC+Local.swift
//  bluezebra
//
//  Created by Harshel Bahl on 22/04/2023.
//

import Foundation
import SwiftUI

extension MessageDC {
    
    /// Local Create Functions
    ///
    func createTextMessage(channelID: String = "personal",
                           userID: String = UserDC.shared.userData!.userID,
                           type: String = MessageType.text.rawValue,
                           date: Date = DateU.shared.currDT,
                           isSender: Bool = true,
                           message: String) async throws -> SMessage {
        
        let SMO = try await DataPC.shared.createMessage(messageID: UUID().uuidString,
                                                        channelID: channelID,
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
        
        var imageIDs = [String]()
        
        for image in selectedImages {
            
            let resourceID = image.id.uuidString + fileType
            imageIDs.append(resourceID)
            
            guard let url = image.url else { throw DCError.nilError(func: "MessageDC.createImageMessage", err: "image URL is nil") }
            
            let imageData = try Data(contentsOf: url)
            
            guard let uiImage = UIImage(data: imageData) else { throw DCError.imageDataFailure(func: "MessageDC.createImageMessage", err: "failed to create UIImage from Data") }
            
            try await self.storeImage(image: uiImage,
                                      name: resourceID,
                                      channelID: channelID)
        }
        
        let SMO = try await DataPC.shared.createMessage(messageID: UUID().uuidString,
                                                        channelID: channelID,
                                                        userID: userID,
                                                        type: type,
                                                        date: date,
                                                        isSender: isSender,
                                                        message: message,
                                                        imageIDs: imageIDs)
        
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
    
    /// Local Sync Functions
    ///
    func syncMessageDC() async throws {
        
        try await self.syncChannel()
        
        for channel in ChannelDC.shared.RUChannels {
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
            
            let SMOs = try await DataPC.shared.fetchSMOs(entity: Message.self,
                                                         customPredicate: predicate,
                                                         fetchLimit: fetchLimit,
                                                         sortKey: sortKey,
                                                         sortAscending: sortAscending)
            DispatchQueue.main.async {
                self.channelMessages[channelID]?.append(contentsOf: SMOs)
            }
        }
    }
    
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
                    channelID: String,
                    compressionQuality: Double = 0.65,
                    fileType: String = ".jpg") async throws {
        
        guard let imageData = image.jpegData(compressionQuality: compressionQuality) else {
            throw DCError.imageDataFailure(func: "MessageDC.fetchImage", err: "channelID: \(channelID), imageName: \(name)")
        }
        
        try await DataPC.shared.storeFile(data: imageData,
                                          fileName: name.hasSuffix(fileType) ? name : name + fileType,
                                          intermidDirs: [channelID, "images"])
    }
    
    func fetchThumbnailImage(imageName: String,
                             channelID: String,
                             maxDimension: CGFloat = 100) async throws -> UIImage {
        let thumbnail = try await DataPC.shared.scaledImage(imageName: imageName,
                                                            intermidDirs: [channelID, "images"],
                                                            maxDimension: maxDimension)
        return thumbnail
    }
    
    func fetchImage(imageName: String,
                    channelID: String) async throws -> UIImage {
        
        let imageData = try await DataPC.shared.fetchFile(fileName: imageName,
                                                          intermidDirs: [channelID, "images"])
        
        guard let uiImage = UIImage(data: imageData) else {
            throw DCError.imageDataFailure(func: "MessageDC.fetchImage", err: "channelID: \(channelID), imageName: \(imageName)")
        }
        
        return uiImage
    }
    
    /// Local Fetch Functions
    ///
    func fetchMessages(channelID: String = "personal",
                       fetchLimit: Int = 15,
                       sortKey: String = "date",
                       sortAscending: Bool = false) async throws -> [SMessage] {
        let SMOs = try await DataPC.shared.fetchSMOs(entity: Message.self,
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
    func messageDeletion(channelID: String,
                         message: SMessage) async throws {
        
        let SMessage = try await DataPC.shared.updateMO(entity: Message.self,
                                                        predicateProperty: "messageID",
                                                        predicateValue: message.messageID,
                                                        property: ["type", "message", "imageIDs", "fileIDs", "localDeleted"],
                                                        value: ["deleted", "", "", "", true])
        
        if let messages = self.channelMessages[channelID],
           let index = messages.firstIndex(where: { $0.messageID == message.messageID }) {
            DispatchQueue.main.async {
                withAnimation(.easeOut(duration: 0.75)) {
                    self.channelMessages[channelID]?[index] = SMessage
                }
            }
        }
        
        if let imageIDs = message.imageIDs?.components(separatedBy: ",") {
            for imageID in imageIDs {
                try await DataPC.shared.removeFile(fileName: imageID,
                                                   intermidDirs: [channelID, "images"])
            }
        }
    }
    
    func deleteMessage(channelID: String,
                       messageID: String) async throws {
        
        self.removeMessage(channelID: channelID,
                           messageID: messageID)
        
        try await DataPC.shared.fetchDeleteMO(entity: Message.self,
                                              predicateProperty: "messageID",
                                              predicateValue: messageID)
    }
    
    func clearChannelMessages(channelID: String) async throws {
        
        self.removeChannelMessages(channelID: channelID)
        
        try await DataPC.shared.fetchDeleteMOs(entity: Message.self,
                                               predicateProperty: "channelID",
                                               predicateValue: channelID)
        
        try await DataPC.shared.clearDir(dir: "images",
                                         intermidDirs: [channelID])
        
        try await DataPC.shared.clearDir(dir: "files",
                                         intermidDirs: [channelID])
    }
    
    func deleteChannelMessages(channelID: String) async throws {
        
        self.removeChannel(channelID: channelID)
        
        try await DataPC.shared.fetchDeleteMOs(entity: Message.self,
                                               predicateProperty: "channelID",
                                               predicateValue: channelID)
    }
    
    func shutdown() {
        DispatchQueue.main.async {
            
        }
        
#if DEBUG
        DataU.shared.handleSuccess(function: "MessageDC.shutdown")
#endif
        
    }
    
}
