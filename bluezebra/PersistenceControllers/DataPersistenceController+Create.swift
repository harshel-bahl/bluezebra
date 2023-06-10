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
    public func createUser(userID: String = UUID().uuidString,
                           username: String,
                           creationDate: Date,
                           pin: String,
                           avatar: String,
                           lastOnline: Date? = nil,
                           completion: @escaping (Result<SUser, PError>)->()) {
        
        self.backgroundContext.perform {
            let fetchRequest = NSFetchRequest<User>(entityName: "User")
            
            do {
                let MOs = try self.backgroundContext.fetch(fetchRequest)
                
                if (MOs.isEmpty==true) {
                    
                    let MO = User(context: self.backgroundContext)
                    MO.userID = userID
                    MO.username = username
                    MO.creationDate = creationDate
                    MO.pin = pin
                    MO.avatar = avatar
                    MO.lastOnline = lastOnline

                    try self.backgroundSave()
                    print("CLIENT \(DateU.shared.logTS) -- DataPC.createUser: SUCCESS")
                    
                    let sMO = try MO.safeObject()
                    
                    DispatchQueue.main.async {
                        completion(.success(sMO))
                    }
                } else {
                    throw PError.recordExists
                }
            } catch {
                print("CLIENT \(DateU.shared.logTS) -- DataPC.createUser: FAILED (\(error))")
                
                DispatchQueue.main.async {
                    completion(.failure(error as? PError ?? .failed))
                }
            }
        }
    }
    
    public func createSettings(biometricSetup: Bool,
                               completion: @escaping (Result<SSettings, PError>)->()) {
        self.backgroundContext.perform {
            do {
                let MO = Settings(context: self.backgroundContext)
                MO.biometricSetup = biometricSetup
                
                try self.backgroundSave()
                print("CLIENT \(DateU.shared.logTS) -- DataPC.createSettings: SUCCESS")
                
                let sMO = try MO.safeObject()
                
                DispatchQueue.main.async {
                    completion(.success(sMO))
                }
            } catch {
                print("CLIENT \(DateU.shared.logTS) -- DataPC.createSettings: FAILED (\(error))")
                
                DispatchQueue.main.async {
                    completion(.failure(error as? PError ?? .failed))
                }
            }
        }
    }
    
    public func createRemoteUser(userID: String,
                                 active: Bool = false,
                                 username: String,
                                 avatar: String,
                                 lastOnline: Date? = nil,
                                 blocked: Bool = false) async throws -> SRemoteUser {
        
        let fetchedMO = try? await fetchMOAsync(entity: RemoteUser.self,
                                                predicateProperty: "userID",
                                                predicateValue: userID)
        
        if fetchedMO != nil { throw PError.recordExists}
        
        let sMO = try await self.backgroundContext.perform {
            do {
                let MO = RemoteUser(context: self.backgroundContext)
                MO.userID = userID
                MO.active = active
                MO.username = username
                MO.avatar = avatar
                MO.lastOnline = lastOnline
                MO.blocked = blocked
                
                try self.backgroundSave()
                
                print("CLIENT \(DateU.shared.logTS) -- DataPC.createRemoteUser: SUCCESS")
                
                let sMO = try MO.safeObject()
                
                return sMO
            } catch {
                print("CLIENT \(DateU.shared.logTS) -- DataPC.createRemoteUser: FAILED (\(error))")
                throw error as? PError ?? .failed
            }
        }
        return sMO
    }
    
    public func createTeam(teamID: String = UUID().uuidString,
                           active: Bool = false,
                           userIDs: [String],
                           nUsers: Int,
                           leads: String,
                           name: String,
                           icon: String,
                           creationUserID: String,
                           creationDate: Date,
                           teamDescription: String? = nil) async throws -> STeam {
        
        let fetchedMO = try? await fetchMOAsync(entity: Team.self,
                                                predicateProperty: "teamID",
                                                predicateValue: teamID)
        
        if fetchedMO != nil { throw PError.recordExists}
        
        let sMO = try await self.backgroundContext.perform {
            do {
                let MO = Team(context: self.backgroundContext)
                MO.teamID = teamID
                MO.active = active
                MO.userIDs = userIDs.joined(separator: ",")
                MO.nUsers = nUsers
                MO.leads = leads
                MO.name = name
                MO.icon = icon
                MO.creationUserID = creationUserID
                MO.creationDate = creationDate
                MO.teamDescription = teamDescription
                
                try self.backgroundSave()
                
                print("CLIENT \(DateU.shared.logTS) -- DataPC.createTeam: SUCCESS")
                
                let sMO = try MO.safeObject()
                
                return sMO
            } catch {
                print("CLIENT \(DateU.shared.logTS) -- DataPC.createTeam: FAILED (\(error))")
                throw error as? PError ?? .failed
            }
        }
        return sMO
    }
    
    public func createChannelRequest(channelID: String = UUID().uuidString,
                                     userID: String? = nil,
                                     teamID: String? = nil,
                                     date: Date,
                                     isSender: Bool,
                                     requestingUserID: String? = nil) async throws -> SChannelRequest {
        
        var customPredicate: NSPredicate? = nil
        
        if let userID = userID {
            customPredicate = NSPredicate(format: "userID == %@", userID)
        } else if let teamID = teamID {
            customPredicate = NSPredicate(format: "teamID == %@", teamID)
        }
        
        guard let customPredicate = customPredicate else { throw PError.failed }
        
        let fetchedMO = try? await fetchMOAsync(entity: ChannelRequest.self,
                                                customPredicate: customPredicate)
        
        if fetchedMO != nil { throw PError.recordExists }
        
        let sMO = try await self.backgroundContext.perform {
            do {
                let MO = ChannelRequest(context: self.backgroundContext)
                MO.channelID = channelID
                MO.userID = userID
                MO.teamID = teamID
                MO.date = date
                MO.isSender = isSender
                MO.requestingUserID = requestingUserID
                
                try self.backgroundSave()
                
                print("CLIENT \(DateU.shared.logTS) -- DataPC.createChannelRequest: SUCCESS")
                
                let sMO = try MO.safeObject()
                
                return sMO
            } catch {
                print("CLIENT \(DateU.shared.logTS) -- DataPC.createChannelRequest: FAILED (\(error))")
                throw error as? PError ?? .failed
            }
        }
        return sMO
    }
    
    public func createChannel(channelID: String = UUID().uuidString,
                              active: Bool = false,
                              channelType: String,
                              userID: String? = nil,
                              teamID: String? = nil,
                              creationUserID: String,
                              creationDate: Date? = nil,
                              lastMessageDate: Date? = nil) async throws -> SChannel {
        
        var customPredicate: NSPredicate? = nil
        
        if let userID = userID {
            customPredicate = NSPredicate(format: "userID == %@", userID)
        } else if let teamID = teamID {
            customPredicate = NSPredicate(format: "teamID == %@", teamID)
        }
        
        guard let customPredicate = customPredicate else { throw PError.failed }
        
        let fetchedMO = try? await fetchMOAsync(entity: Channel.self,
                                                customPredicate: customPredicate)
        
        if fetchedMO != nil { throw PError.recordExists }
        
        let sMO = try await self.backgroundContext.perform {
            do {
                let MO = Channel(context: self.backgroundContext)
                MO.channelID = channelID
                MO.active = active
                MO.channelType = channelType
                MO.userID = userID
                MO.teamID = teamID
                MO.creationUserID = creationUserID
                MO.creationDate = creationDate
                MO.lastMessageDate = lastMessageDate
                
                try self.backgroundSave()
                
                print("CLIENT \(DateU.shared.logTS) -- DataPC.createChannel: SUCCESS")
                
                let sMO = try MO.safeObject()
                
                return sMO
            } catch {
                print("CLIENT \(DateU.shared.logTS) -- DataPC.createChannel: FAILED (\(error))")
                throw error as? PError ?? .failed
            }
        }
        return sMO
    }
    
    public func createChannelDeletion(deletionID: String = UUID().uuidString,
                                      channelType: String,
                                      deletionDate: Date,
                                      type: String,
                                      name: String,
                                      icon: String,
                                      nUsers: Int,
                                      toDeleteUserIDs: [String] = [String](),
                                      isOrigin: Bool) async throws -> SChannelDeletion {
        
        let sMO = try await self.backgroundContext.perform {
            do {
                let MO = ChannelDeletion(context: self.backgroundContext)
                MO.deletionID = deletionID
                MO.channelType = channelType
                MO.deletionDate = deletionDate
                MO.type = type
                MO.name = name
                MO.icon = icon
                MO.nUsers = nUsers
                MO.toDeleteUserIDs = toDeleteUserIDs.joined(separator: ",")
                MO.isOrigin = isOrigin
                
                try self.backgroundSave()
                
                print("CLIENT \(DateU.shared.logTS) -- DataPC.createChannelDeletion: SUCCESS")
                
                let sMO = try MO.safeObject()
                
                return sMO
            } catch {
                print("CLIENT \(DateU.shared.logTS) -- DataPC.createChannelDeletion: FAILED (\(error))")
                throw error as? PError ?? .failed
            }
        }
        return sMO
    }
    
    public func createMessage(messageID: String = UUID().uuidString,
                              channelID: String,
                              userID: String,
                              type: String,
                              date: Date,
                              message: String,
                              isSender: Bool,
                              sent: [String]? = [String](),
                              delivered: [String]? = [String](),
                              read: [String]? = [String](),
                              remoteDeleted: [String]? = [String]()) async throws -> SMessage {
        
        let fetchedMO = try? await fetchMOAsync(entity: Message.self,
                                                predicateProperty: "messageID",
                                                predicateValue: messageID)
        
        if fetchedMO != nil { throw PError.recordExists}
        
        let sMO = try await self.backgroundContext.perform {
            do {
                let MO = Message(context: self.backgroundContext)
                MO.messageID = messageID
                MO.channelID = channelID
                MO.userID = userID
                MO.type = type
                MO.date = date
                MO.message = message
                MO.isSender = isSender
                if let sent = sent { MO.sent = sent.joined(separator: ",") }
                if let delivered = delivered { MO.delivered = delivered.joined(separator: ",") }
                if let read = read { MO.read = read.joined(separator: ",") }
                if let remoteDeleted = remoteDeleted { MO.remoteDeleted = remoteDeleted.joined(separator: ",") }
                
                try self.backgroundSave()
                
                print("CLIENT \(DateU.shared.logTS) -- DataPC.createMessage: SUCCESS")
                
                let sMO = try MO.safeObject()
                
                return sMO
            } catch {
                print("CLIENT \(DateU.shared.logTS) -- DataPC.createMessage: FAILED (\(error))")
                throw error as? PError ?? .failed
            }
        }
        return sMO
    }
    
}

