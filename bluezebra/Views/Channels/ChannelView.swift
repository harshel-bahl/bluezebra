//
//  ChannelView.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 07/02/2023.
//

import SwiftUI
import CoreData

struct ChannelView: View {
    
    @ObservedObject var channelDC = ChannelDC.shared
    @ObservedObject var messageDC = MessageDC.shared
    
    let channel: SChannel
    @State var remoteUser: SRemoteUser?
    @State var latestMessage: SMessage?
    
    @State var showChat = false
    
    init(channel: SChannel) {
        self.channel = channel
        if let remoteUserID = channel.userID,
           let remoteUser = channelDC.remoteUsers[remoteUserID] {
            self.remoteUser = remoteUser
        } else {
            // check for user otherwise retrieve info from server
        }
    }
    
    var body: some View {
        ZStack {
            if let remoteUser = remoteUser {
                NavigationLink("chatLink", destination: ChatView(channel: channel,
                                                                 remoteUser: remoteUser), isActive: $showChat)
            }
            
            ZStack {
                Color("background1")
                
                HStack {
                    Image(systemName: "person.fill")
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 45, height: 45)
                        .foregroundColor(Color.white)
                    
                    VStack {
                        HStack {
                            username
                            
                            onlineBadge
                            
                            Spacer()
                        }
                    }
                }
            }
            .onTapGesture {
                showChat = true
            }
            .swipeActions() {
                Button("Clear") {
                    //                    channelDC.deleteChannel(channel: channel) {_ in}
                }
                .tint(Color.orange)
                
                Button("Delete") {
                    //                    channelDC.deleteChannel(channel: channel,
                    //                                                        type: "delete") {_ in}
                }
                .tint(Color.red)
            }
        }
    }
    
    var username: some View {
        let usernameView = Text(remoteUser?.username ?? "").padding(.leading).foregroundColor(Color.white)
        return usernameView
    }
    
    var onlineBadge: some View {
        guard let remoteUser = remoteUser else { return Text("-").foregroundColor(.white).fontWeight(.bold) }
        
        if let online = channelDC.onlineUsers[remoteUser.userID],
           online == true {
            return Text("Online").foregroundColor(.green).fontWeight(.bold)
        } else {
//            guard let lastOnline = remoteUser.lastOnline,
//                  let lastOnlineString = DateU.shared.stringFromDate(lastOnline) else {
                return Text("-").foregroundColor(.white).fontWeight(.bold)
//            }
            
//            let badge = Text(lastOnlineString).foregroundColor(.white).fontWeight(.bold)
//            return badge
        }
    }
}
