//
//  DataPC+Reset.swift
//  bluezebra
//
//  Created by Harshel Bahl on 15/04/2023.
//

import Foundation
import CoreData

extension DataPC {
    
    /// Reset DataPC Functions
    ///
    
    public func hardResetDataPC(completion:()->()) {
        self.fetchDeleteMOs(entity: User.self) {_ in}
        self.fetchDeleteMOs(entity: Settings.self) {_ in}
        self.fetchDeleteMOs(entity: RemoteUser.self) {_ in}
        self.fetchDeleteMOs(entity: Team.self) {_ in}
        self.fetchDeleteMOs(entity: Channel.self) {_ in}
        self.fetchDeleteMOs(entity: ChannelRequest.self) {_ in}
        self.fetchDeleteMOs(entity: ChannelDeletion.self) {_ in}
        self.fetchDeleteMOs(entity: Message.self) {_ in}
        completion()
    }
}
