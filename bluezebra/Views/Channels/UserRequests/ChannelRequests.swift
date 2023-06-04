//
//  ChannelRequests.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 25/03/2023.
//

import Foundation
import SwiftUI

struct ChannelRequests: View {
    
    @ObservedObject var userDC = UserDC.shared
    @ObservedObject var channelDC = ChannelDC.shared
    
    @State var username = ""
    
    var body: some View {
        VStack {
            List {
                ForEach(channelDC.channelRequests, id: \.channelID) { channelRequest in
                    ChannelRequestRow(channelRequest: channelRequest)
                }
            }
        }
    }
}
