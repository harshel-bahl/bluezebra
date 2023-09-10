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
    public func createUser(uID: UUID,
                           username: String,
                           creationDate: Date,
                           avatar: String,
                           lastOnline: Date? = nil,
                           settings: Settings? = nil) throws -> User {
        do {
            let checkMO = try? self.fetchMO(entity: User.self,
                                            queue: "background")
            
            if checkMO != nil { throw PError.recordExists(err: "user object already exists in database") }
            
            let MO = User(context: self.backgroundContext)
            MO.uID = uID
            MO.username = username
            MO.creationDate = creationDate
            MO.avatar = avatar
            MO.lastOnline = lastOnline
            
            if let settings = settings {
                MO.settings = settings
            }
            
            log.debug(message: "created user object in database", function: "DataPC.createUser", info: "uID: \(uID)")
            
            return MO
        } catch {
            log.error(message: "failed to create user object in database", function: "DataPC.createUser", error: error, info: "uID: \(uID)")
            throw error
        }
    }
    
    /// createSettings
    ///
    public func createSettings(biometricSetup: String? = nil,
                               user: User? = nil) throws -> Settings {
        do {
            let checkMO = try? self.fetchMO(entity: Settings.self,
                                            queue: "background")
            
            if checkMO != nil { throw PError.recordExists(err: "settings object already exists in database") }
            
            let MO = Settings(context: self.backgroundContext)
            MO.biometricSetup = biometricSetup
            
            if let user = user {
                MO.user = user
            }
            
            log.debug(message: "created settings object in database", function: "DataPC.createSettings")
            
            return MO
        } catch {
            log.error(message: "failed to create settings object in database", function: "DataPC.createSettings", error: error)
            throw error
        }
    }
    
    /// createRU
    ///
    public func createRU(uID: UUID,
                         username: String,
                         avatar: String,
                         creationDate: Date,
                         lastOnline: Date? = nil,
                         blocked: Bool = false,
                         channel: Channel? = nil,
                         channelRequest: ChannelRequest? = nil) throws -> RemoteUser {
        do {
            let checkMO = try? fetchMO(entity: RemoteUser.self,
                                       queue: "background",
                                       predDicEqual: ["uID": uID])
            
            if checkMO != nil { throw PError.recordExists(err: "RU object already exists in database") }
            
            let MO = RemoteUser(context: self.backgroundContext)
            MO.uID = uID
            MO.username = username
            MO.avatar = avatar
            MO.creationDate = creationDate
            MO.lastOnline = lastOnline
            MO.blocked = blocked
            
            if let channel = channel {
                MO.channel = channel
            }
            
            if let channelRequest = channelRequest {
                MO.channelRequest = channelRequest
            }
            
            log.debug(message: "created RU", function: "DataPC.createRU", info: "uID: \(uID)")
            
            return MO
        } catch {
            log.error(message: "failed to create RU", function: "DataPC.createRU", error: error, info: "uID: \(uID)")
            throw error
        }
    }
    
    /// createChannel
    /// - Creates a channel attributed to one userID, so no duplicates
    public func createChannel(channelID: UUID,
                              uID: UUID,
                              channelType: String,
                              creationDate: Date,
                              lastMessageDate: Date? = nil,
                              remoteUser: RemoteUser? = nil) throws -> Channel {
        do {
            let checkMO = try? fetchMO(entity: Channel.self,
                                       queue: "background",
                                       predDicEqual: ["channelID": channelID])
            
            if checkMO != nil { throw PError.recordExists() }
            
            let MO = Channel(context: self.backgroundContext)
            MO.channelID = channelID
            MO.uID = uID
            MO.channelType = channelType
            MO.creationDate = creationDate
            MO.lastMessageDate = lastMessageDate
            
            if let remoteUser = remoteUser {
                MO.remoteUser = remoteUser
            }
            
            log.debug(message: "created channel", function: "DataPC.createChannel", info: "channelID: \(channelID)")
            
            return MO
        } catch {
            log.error(message: "failed to create channel", function: "DataPC.createChannel", error: error, info: "channelID: \(channelID)")
            throw error
        }
    }
    
    /// createCR
    ///
    public func createCR(requestID: UUID,
                         uID: UUID,
                         date: Date,
                         isSender: Bool,
                         remoteUser: RemoteUser? = nil) throws -> ChannelRequest {
        do {
            let checkMO = try? fetchMO(entity: ChannelRequest.self,
                                       queue: "background",
                                       predDicEqual: ["requestID": requestID])
            
            if checkMO != nil { throw PError.recordExists(err: "CR object already exists in database") }
            
            let MO = ChannelRequest(context: self.backgroundContext)
            MO.requestID = requestID
            MO.uID = uID
            MO.date = date
            MO.isSender = isSender
            
            if let remoteUser = remoteUser {
                MO.remoteUser = remoteUser
            }
            
            log.debug(message: "created CR", function: "DataPC.createCR", info: "requestID: \(requestID), uID: \(uID)")
            
            return MO
        } catch {
            log.error(message: "failed to create CR", function: "DataPC.createCR", error: error, info: "requestID: \(requestID), uID: \(uID)")
            throw error
        }
    }
    
    /// createCD
    ///
    public func createCD(deletionID: UUID,
                         channelType: String,
                         deletionDate: Date,
                         type: String,
                         name: String,
                         icon: String,
                         nUsers: Int16,
                         toDeleteUID: [UUID],
                         isOrigin: Bool) throws -> ChannelDeletion {
        do {
            let checkMO = try? fetchMO(entity: ChannelDeletion.self,
                                       queue: "background",
                                       predDicEqual: ["deletionID": deletionID])
            
            if checkMO != nil { throw PError.recordExists(err: "CD object already exists in database") }
            
            let MO = ChannelDeletion(context: self.backgroundContext)
            MO.deletionID = deletionID
            MO.channelType = channelType
            MO.deletionDate = deletionDate
            MO.type = type
            MO.name = name
            MO.icon = icon
            MO.nUsers = nUsers
            MO.toDeleteUID = toDeleteUID.map({ $0.uuidString }).joined(separator: ",")
            MO.isOrigin = isOrigin
            
            log.debug(message: "created CD", function: "DataPC.createCD", info: "deletionID: \(deletionID)")
            
            return MO
        } catch {
            log.error(message: "failed to create CD", function: "DataPC.createCD", error: error, info: "deletionID: \(deletionID)")
            throw error
        }
    }
    
    /// createMessage
    ///
    public func createMessage(messageID: UUID,
                              channelID: UUID,
                              uID: UUID,
                              date: Date,
                              isSender: Bool,
                              message: String? = nil,
                              imageIDs: [UUID]? = nil,
                              fileIDs: [UUID]? = nil,
                              sent: [UUID]? = nil,
                              delivered: [UUID]? = nil,
                              read: [UUID]? = nil,
                              localDeleted: Bool = false,
                              remoteDeleted: [UUID]? = nil,
                              channel: Channel? = nil,
                              remoteUser: RemoteUser? = nil) throws -> Message {
        do {
            let checkMO = try? fetchMO(entity: Message.self,
                                       queue: "background",
                                       predDicEqual: ["messageID": messageID])
            
            if checkMO != nil { throw PError.recordExists(err: "message object already exists in database") }
            
            let MO = Message(context: self.backgroundContext)
            MO.messageID = messageID
            MO.channelID = channelID
            MO.uID = uID
            MO.date = date
            MO.isSender = isSender
            MO.message = message
            if let imageIDs = imageIDs { MO.imageIDs = imageIDs.map({ $0.uuidString }).joined(separator: ",") }
            if let fileIDs = fileIDs { MO.fileIDs = fileIDs.map({ $0.uuidString }).joined(separator: ",") }
            if let sent = sent { MO.sent = sent.map({ $0.uuidString }).joined(separator: ",") }
            if let delivered = delivered { MO.delivered = delivered.map({ $0.uuidString }).joined(separator: ",") }
            if let read = read { MO.read = read.map({ $0.uuidString }).joined(separator: ",") }
            MO.localDeleted = localDeleted
            if let remoteDeleted = remoteDeleted { MO.remoteDeleted = remoteDeleted.map({ $0.uuidString }).joined(separator: ",") }
            
            if let channel = channel {
                MO.channel = channel
            }
            
            if let remoteUser = remoteUser {
                MO.remoteUser = remoteUser
            }
            
            log.debug(message: "created message", function: "DataPC.createMessage", info: "messageID: \(messageID)")
            
            return MO
        } catch {
            log.error(message: "failed to create message", function: "DataPC.createMessage", error: error, info: "messageID: \(messageID)")
            throw error
        }
    }
    
    /// createEvent
    ///
    public func createEvent(eventID: UUID,
                            eventName: String,
                            date: Date,
                            recUID: UUID,
                            packet: Data) throws -> Event {
        do {
            let checkMO = try? fetchMO(entity: Event.self,
                                       queue: "background",
                                       predDicEqual: ["eventID": eventID])
            
            if checkMO != nil { throw PError.recordExists(err: "event object already exists in database") }
            
            let MO = Event(context: self.backgroundContext)
            MO.eventID = eventID
            MO.eventName = eventName
            MO.date = date
            MO.recUID = recUID
            MO.packet = packet
            
            log.debug(message: "created message", function: "DataPC.createMessage", info: "eventID: \(eventID), eventName: \(eventName)")
            
            return MO
        } catch {
            log.error(message: "failed to create event", function: "DataPC.createEvent", error: error, info: "eventID: \(eventID), eventName: \(eventName)")
            throw error
        }
    }
    
}

