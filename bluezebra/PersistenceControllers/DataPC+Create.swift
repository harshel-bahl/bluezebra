//
//  DataPC+Create.swift
//  bluezebra
//
//  Created by Harshel Bahl on 15/04/2023.
//

import Foundation
import CoreData

extension DataPC {
    
    /// Creation Persistence Functions
    /// Write operations on background thread
    ///
    
    /// createUser
    ///
    public func createUser(userID: String,
                           username: String,
                           creationDate: Date,
                           avatar: String,
                           lastOnline: Date? = nil) async throws -> SUser {
        
        let checkMO = try? await self.fetchMO(entity: User.self)
        
        if checkMO != nil { throw PError.recordExists(func: "DataPC.createUser", err: "userID: \(userID)") }
        
        let SMO = try await self.backgroundContext.perform {
            let MO = User(context: self.backgroundContext)
            MO.userID = userID
            MO.username = username
            MO.creationDate = creationDate
            MO.avatar = avatar
            MO.lastOnline = lastOnline
            
            try self.backgroundSave()
            
            let SMO = try MO.safeObject()
            
            return SMO
        }
        
#if DEBUG
        DataU.shared.handleSuccess(function: "DataPC.createUser", info: "userID: \(userID)")
#endif
        
        return SMO
    }
    
    /// createSettings
    ///
    public func createSettings(pin: String,
                               biometricSetup: String? = nil) async throws -> SSettings {
        
        let checkMO = try? await self.fetchMO(entity: Settings.self)
        
        if checkMO != nil { throw PError.recordExists(func: "DataPC.createSettings") }
        
        let SMO = try await self.backgroundContext.perform {
            let MO = Settings(context: self.backgroundContext)
            MO.pin = pin
            MO.biometricSetup = biometricSetup
            
            try self.backgroundSave()
            
            let SMO = try MO.safeObject()
            
            return SMO
        }
        
#if DEBUG
        DataU.shared.handleSuccess(function: "DataPC.createSettings")
#endif
        
        return SMO
    }
    
    /// createRU
    ///
    public func createRU(userID: String,
                         username: String,
                         avatar: String,
                         creationDate: Date,
                         lastOnline: Date? = nil,
                         blocked: Bool = false) async throws -> SRemoteUser {
        
        let fetchedMO = try? await fetchMO(entity: RemoteUser.self,
                                           predicateProperty: "userID",
                                           predicateValue: userID)
        
        if fetchedMO != nil { throw PError.recordExists(func: "DataPC.createRU", err: "userID: \(userID)") }
        
        let sMO = try await self.backgroundContext.perform {
            let MO = RemoteUser(context: self.backgroundContext)
            MO.userID = userID
            MO.username = username
            MO.avatar = avatar
            MO.creationDate = creationDate
            MO.lastOnline = lastOnline
            MO.blocked = blocked
            
            try self.backgroundSave()
            
            let sMO = try MO.safeObject()
            
            return sMO
        }
        
        
#if DEBUG
        DataU.shared.handleSuccess(function: "DataPC.createRU", info: "userID: \(userID)")
#endif
        
        return sMO
    }
    
    /// createCR
    ///
    public func createCR(requestID: String,
                         userID: String,
                         date: Date,
                         isSender: Bool) async throws -> SChannelRequest {
        
        let checkMO = try? await fetchMO(entity: ChannelRequest.self,
                                         predicateProperty: "requestID",
                                         predicateValue: requestID)
        
        if checkMO != nil { throw PError.recordExists(func: "DataPC.createCR", err: "requestID: \(requestID)") }
        
        let sMO = try await self.backgroundContext.perform {
            let MO = ChannelRequest(context: self.backgroundContext)
            MO.requestID = requestID
            MO.userID = userID
            MO.date = date
            MO.isSender = isSender
            
            try self.backgroundSave()
            
            let sMO = try MO.safeObject()
            
            return sMO
        }
        
        
#if DEBUG
        DataU.shared.handleSuccess(function: "DataPC.createCR", info: "requestID: \(requestID)")
#endif
        
        return sMO
    }
    
    /// createChannel
    /// - Creates a channel attributed to one userID, so no duplicates
    public func createChannel(channelID: String,
                              userID: String,
                              creationDate: Date,
                              lastMessageDate: Date? = nil) async throws -> SChannel {
        
        let checkMO = try? await fetchMO(entity: Channel.self,
                                         predicateProperty: "channelID",
                                         predicateValue: channelID)
        
        if checkMO != nil { throw PError.recordExists(func: "DataPC.createChannel", err: "channelID: \(channelID)") }
        
        let sMO = try await self.backgroundContext.perform {
            
            let MO = Channel(context: self.backgroundContext)
            MO.channelID = channelID
            MO.userID = userID
            MO.creationDate = creationDate
            MO.lastMessageDate = lastMessageDate
            
            try self.backgroundSave()
            
            let sMO = try MO.safeObject()
            
            return sMO
        }
        
#if DEBUG
        DataU.shared.handleSuccess(function: "DataPC.createChannel", info: "channelID: \(channelID)")
#endif
        
        return sMO
    }
    
    /// createCD
    ///
    public func createCD(deletionID: String,
                         channelType: String,
                         deletionDate: Date,
                         type: String,
                         name: String,
                         icon: String,
                         nUsers: Int16,
                         toDeleteUserIDs: [String]? = nil,
                         isOrigin: Bool) async throws -> SChannelDeletion {
        
        let checkMO = try? await fetchMO(entity: ChannelDeletion.self,
                                         predicateProperty: "deletionID",
                                         predicateValue: deletionID)
        
        if checkMO != nil { throw PError.recordExists(func: "DataPC.createCD", err: "deletionID: \(deletionID)") }
        
        let sMO = try await self.backgroundContext.perform {
            let MO = ChannelDeletion(context: self.backgroundContext)
            MO.deletionID = deletionID
            MO.channelType = channelType
            MO.deletionDate = deletionDate
            MO.type = type
            MO.name = name
            MO.icon = icon
            MO.nUsers = nUsers
            
            if let toDeleteUserIDs = toDeleteUserIDs {
                MO.toDeleteUserIDs = toDeleteUserIDs.joined(separator: ",")
            }
            
            MO.isOrigin = isOrigin
            
            try self.backgroundSave()
            
            let sMO = try MO.safeObject()
            
            return sMO
        }
        
#if DEBUG
        DataU.shared.handleSuccess(function: "DataPC.createCD", info: "deletionID: \(deletionID)")
#endif
        
        return sMO
    }
    
    /// createMessage
    ///
    public func createMessage(messageID: String,
                              channelID: String,
                              userID: String,
                              type: String,
                              date: Date,
                              isSender: Bool,
                              message: String,
                              imageIDs: [String]? = nil,
                              fileIDs: [String]? = nil,
                              sent: [String]? = nil,
                              delivered: [String]? = nil,
                              read: [String]? = nil,
                              localDeleted: Bool = false,
                              remoteDeleted: [String]? = nil) async throws -> SMessage {
        
        let checkMO = try? await fetchMO(entity: Message.self,
                                         predicateProperty: "messageID",
                                         predicateValue: messageID)
        
        if checkMO != nil { throw PError.recordExists(func: "DataPC.createMessage", err: "messageID: \(messageID)") }
        
        let SMO = try await self.backgroundContext.perform {
            let MO = Message(context: self.backgroundContext)
            MO.messageID = messageID
            MO.channelID = channelID
            MO.userID = userID
            MO.type = type
            MO.date = date
            MO.isSender = isSender
            MO.message = message
            if let imageIDs = imageIDs { MO.imageIDs = imageIDs.joined(separator: ",") }
            if let fileIDs = fileIDs { MO.fileIDs = fileIDs.joined(separator: ",") }
            if let sent = sent { MO.sent = sent.joined(separator: ",") }
            if let delivered = delivered { MO.delivered = delivered.joined(separator: ",") }
            if let read = read { MO.read = read.joined(separator: ",") }
            MO.localDeleted = localDeleted
            if let remoteDeleted = remoteDeleted { MO.remoteDeleted = remoteDeleted.joined(separator: ",") }
            
            try self.backgroundSave()
            
            let SMO = try MO.safeObject()
            
            return SMO
        }
        
#if DEBUG
        DataU.shared.handleSuccess(function: "DataPC.createMessage", info: "messageID: \(messageID)")
#endif
        
        return SMO
    }
    
    /// createEvent
    ///
    public func createEvent(eventID: String,
                            eventName: String,
                            date: Date,
                            userID: String,
                            attempts: Int16,
                            packet: Data) async throws -> SEvent {
        
        let checkMO = try? await fetchMO(entity: Event.self,
                                         predicateProperty: "eventID",
                                         predicateValue: eventID)
        
        if checkMO != nil { throw PError.recordExists(func: "DataPC.createEvent", err: "eventID: \(eventID)") }
        
        let SMO = try await self.backgroundContext.perform {
            let MO = Event(context: self.backgroundContext)
            MO.eventID = eventID
            MO.eventName = eventName
            MO.date = date
            MO.userID = userID
            MO.attempts = attempts
            MO.packet = packet
            
            try self.backgroundSave()
            
            let SMO = try MO.safeObject()
            
            return SMO
        }
        
#if DEBUG
        DataU.shared.handleSuccess(function: "DataPC.createEvent", info: "eventID: \(eventID)")
#endif
        
        return SMO
    }
    
}

