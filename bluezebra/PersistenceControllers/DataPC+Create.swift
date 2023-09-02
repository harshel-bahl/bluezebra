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
    public func createUser(UID: String,
                           username: String,
                           creationDate: Date,
                           avatar: String,
                           lastOnline: Date? = nil) async throws -> SUser {
        do {
            let checkMO = try? await self.fetchMO(entity: User.self)
            
            if checkMO != nil { throw PError.recordExists() }
            
            let SMO = try await self.backgroundContext.perform {
                let MO = User(context: self.backgroundContext)
                MO.userID = UID
                MO.username = username
                MO.creationDate = creationDate
                MO.avatar = avatar
                MO.lastOnline = lastOnline
                
                try self.backgroundSave()
                
                let SMO = try MO.safeObject()
                
                return SMO
            }
            
            log.debug(message: "created user", function: "DataPC.createUser", info: "UID: \(UID)")
            
            return SMO
        } catch {
            log.error(message: "failed to create user", function: "DataPC.createUser", error: error, info: "UID: \(UID)")
            throw error
        }
    }
    
    /// createSettings
    ///
    public func createSettings(pin: String,
                               biometricSetup: String? = nil) async throws -> SSettings {
        do {
            let checkMO = try? await self.fetchMO(entity: Settings.self)
            
            if checkMO != nil { throw PError.recordExists() }
            
            let SMO = try await self.backgroundContext.perform {
                let MO = Settings(context: self.backgroundContext)
                MO.pin = pin
                MO.biometricSetup = biometricSetup
                
                try self.backgroundSave()
                
                let SMO = try MO.safeObject()
                
                return SMO
            }
            
            log.debug(message: "created settings", function: "DataPC.createSettings")
            
            return SMO
        } catch {
            log.error(message: "failed to create settings", function: "DataPC.createSettings", error: error)
            throw error
        }
    }
    
    /// createRU
    ///
    public func createRU(UID: String,
                         username: String,
                         avatar: String,
                         creationDate: Date,
                         lastOnline: Date? = nil,
                         blocked: Bool = false) async throws -> SRemoteUser {
        do {
            let fetchedMO = try? await fetchMO(entity: RemoteUser.self,
                                               predObject: ["userID": UID])
            
            if fetchedMO != nil { throw PError.recordExists() }
            
            let sMO = try await self.backgroundContext.perform {
                let MO = RemoteUser(context: self.backgroundContext)
                MO.userID = UID
                MO.username = username
                MO.avatar = avatar
                MO.creationDate = creationDate
                MO.lastOnline = lastOnline
                MO.blocked = blocked
                
                try self.backgroundSave()
                
                let sMO = try MO.safeObject()
                
                return sMO
            }
            
            log.debug(message: "created RU", function: "DataPC.createRU", info: "RUID: \(UID)")
            
            return sMO
        } catch {
            log.error(message: "failed to create RU", function: "DataPC.createRU", error: error, info: "RUID: \(UID)")
            throw error
        }
    }
    
    /// createCR
    ///
    public func createCR(requestID: String,
                         UID: String,
                         date: Date,
                         isSender: Bool) async throws -> SChannelRequest {
        do {
            let checkMO = try? await fetchMO(entity: ChannelRequest.self,
                                             predObject: ["requestID": requestID])
            
            if checkMO != nil { throw PError.recordExists() }
            
            let sMO = try await self.backgroundContext.perform {
                let MO = ChannelRequest(context: self.backgroundContext)
                MO.requestID = requestID
                MO.userID = UID
                MO.date = date
                MO.isSender = isSender
                
                try self.backgroundSave()
                
                let sMO = try MO.safeObject()
                
                return sMO
            }
            
            log.debug(message: "created CR", function: "DataPC.createCR", info: "requestID: \(requestID)")
            
            return sMO
        } catch {
            log.error(message: "failed to create CR", function: "DataPC.createCR", error: error, info: "requestID: \(requestID)")
            throw error
        }
    }
    
    /// createChannel
    /// - Creates a channel attributed to one userID, so no duplicates
    public func createChannel(channelID: String,
                              UID: String,
                              creationDate: Date,
                              lastMessageDate: Date? = nil) async throws -> SChannel {
        do {
            let checkMO = try? await fetchMO(entity: Channel.self,
                                             predObject: ["channelID": channelID])
            
            if checkMO != nil { throw PError.recordExists() }
            
            let sMO = try await self.backgroundContext.perform {
                
                let MO = Channel(context: self.backgroundContext)
                MO.channelID = channelID
                MO.userID = UID
                MO.creationDate = creationDate
                MO.lastMessageDate = lastMessageDate
                
                try self.backgroundSave()
                
                let sMO = try MO.safeObject()
                
                return sMO
            }
            
            log.debug(message: "created channel", function: "DataPC.createChannel", info: "channelID: \(channelID)")
            
            return sMO
        } catch {
            log.error(message: "failed to create channel", function: "DataPC.createChannel", error: error, info: "channelID: \(channelID)")
            throw error
        }
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
                         toDeleteUIDs: [String]? = nil,
                         isOrigin: Bool) async throws -> SChannelDeletion {
        do {
            let checkMO = try? await fetchMO(entity: ChannelDeletion.self,
                                             predObject: ["deletionID": deletionID])
            
            if checkMO != nil { throw PError.recordExists() }
            
            let sMO = try await self.backgroundContext.perform {
                let MO = ChannelDeletion(context: self.backgroundContext)
                MO.deletionID = deletionID
                MO.channelType = channelType
                MO.deletionDate = deletionDate
                MO.type = type
                MO.name = name
                MO.icon = icon
                MO.nUsers = nUsers
                
                if let toDeleteUIDs = toDeleteUIDs {
                    MO.toDeleteUIDs = toDeleteUIDs.joined(separator: ",")
                }
                
                MO.isOrigin = isOrigin
                
                try self.backgroundSave()
                
                let sMO = try MO.safeObject()
                
                return sMO
            }
            
            log.debug(message: "created CD", function: "DataPC.createCD", info: "deletionID: \(deletionID)")
            
            return sMO
        } catch {
            log.error(message: "failed to create CD", function: "DataPC.createCD", error: error, info: "deletionID: \(deletionID)")
            throw error
        }
    }
    
    /// createMessage
    ///
    public func createMessage(messageID: String,
                              channelID: String,
                              UID: String,
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
        do {
            let checkMO = try? await fetchMO(entity: Message.self,
                                             predObject: ["messageID": messageID])
            
            if checkMO != nil { throw PError.recordExists() }
            
            let SMO = try await self.backgroundContext.perform {
                let MO = Message(context: self.backgroundContext)
                MO.messageID = messageID
                MO.channelID = channelID
                MO.userID = UID
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
            
            log.debug(message: "created message", function: "DataPC.createMessage", info: "messageID: \(messageID)")
            
            return SMO
        } catch {
                log.error(message: "failed to create message", function: "DataPC.createMessage", error: error, info: "messageID: \(messageID)")
                throw error
        }
    }
    
    /// createEvent
    ///
    public func createEvent(eventID: String,
                            eventName: String,
                            date: Date,
                            UID: String,
                            attempts: Int16,
                            packet: Data) async throws -> SEvent {
        do {
            let checkMO = try? await fetchMO(entity: Event.self,
                                             predObject: ["eventID": eventID])
            
            if checkMO != nil { throw PError.recordExists() }
            
            let SMO = try await self.backgroundContext.perform {
                let MO = Event(context: self.backgroundContext)
                MO.eventID = eventID
                MO.eventName = eventName
                MO.date = date
                MO.userID = UID
                MO.attempts = attempts
                MO.packet = packet
                
                try self.backgroundSave()
                
                let SMO = try MO.safeObject()
                
                return SMO
            }
            
            log.debug(message: "created message", function: "DataPC.createMessage", info: "eventID: \(eventID), eventName: \(eventName)")
            
            return SMO
        } catch {
            log.error(message: "failed to create event", function: "DataPC.createEvent", error: error, info: "eventID: \(eventID), eventName: \(eventName)")
            throw error
        }
    }
    
}

