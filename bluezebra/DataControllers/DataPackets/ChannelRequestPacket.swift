//
//  ChannelRequestPacket.swift
//  bluezebra
//
//  Created by Harshel Bahl on 18/04/2023.
//

import Foundation

struct ChannelRequestPacket: Codable {
    var channel: ChannelPacket
    var remoteUser: RemoteUserPacket?
    var teamPacket: TeamPacket?
    var date: String
    var requestingUserID: String?
}
