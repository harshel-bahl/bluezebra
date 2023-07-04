//
//  ChannelView.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 07/02/2023.
//

import SwiftUI
import CoreData

struct ChannelView: View {
    
    @EnvironmentObject var SP: ScreenProperties
    
    @ObservedObject var userDC = UserDC.shared
    @ObservedObject var channelDC = ChannelDC.shared
    @ObservedObject var messageDC = MessageDC.shared
    
    let channel: SChannel
    @State var RU: SRemoteUser?
    @State var latestMessage: SMessage?
    
    @State var showChat = false
    
    @State var scale: CGFloat = 1
    
    init(channel: SChannel) {
        self.channel = channel
        
        if let remoteUserID = channel.userID,
           let remoteUser = channelDC.RUs[remoteUserID] {
            self._RU = State(wrappedValue: remoteUser)
        } else {
            // check for user otherwise retrieve info from server
        }
        
        if let latestMessage = messageDC.userMessages[channel.channelID]?.first {
            self._latestMessage = State(wrappedValue: latestMessage)
        }
    }
    
    var body: some View {
        ZStack {
            NavigationLink {
                if let RU = RU {
                    ChatView(channel: channel, remoteUser: RU)
                }
            } label: {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        VStack(spacing: 0) {
                            
                            if let readReceipt = latestMessage?.read,
                               userDC.userData!.userID == readReceipt  {
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 7.5)
                                    .foregroundColor(Color("blueAccent1"))
                            }
                        }
                        .frame(width: 15)
                        .padding(.trailing, 2.5)
                        
                        ZStack {
//                            if let avatar = RU?.avatar,
//                               let emoji = BZEmojiProvider1.shared.getEmojiByName(name: avatar) {
//                                Text(emoji.value)
//                                    .font(.system(size: 45))
//                                    .frame(width: 45,
//                                           height: 45)
//                                    .onTapGesture {
//                                        // navigate to user profile
//                                    }
//                            } else {
//                                Image(systemName: "person.crop.circle.fill")
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .frame(width: 45,
//                                           height: 45)
//                                    .foregroundColor(Color("blueAccent1"))
//                            }
                            
                            if let RU = RU,
                               let online = channelDC.onlineUsers[RU.userID],
                               online == true {
                                HStack(spacing: 0) {
                                    Circle()
                                        .fill(Color.green)
                                        .scaleEffect(scale)
                                        .animation(Animation.easeInOut(duration: 1.5).repeatForever(), value: scale)
                                        .onAppear {
                                            self.scale = 0.75
                                        }
                                        .frame(width: 8, height: 8)
                                        .offset(y: 1)
                                    
                                    Text("online")
                                        .font(.caption)
                                        .foregroundColor(Color("text2"))
                                        .padding(.leading, 3)
                                }
                                .offset(y: 35)
                            }
                        }
                        
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                if let RU = RU {
                                    Text("@" + RU.username)
                                        .font(.headline)
                                        .foregroundColor(Color("blueAccent1"))
                                } else {
                                    Text("-")
                                        .font(.headline)
                                        .foregroundColor(Color("text1"))
                                        .fontWeight(.bold)
                                }
                                
                                Spacer()
                                
                                if let latestDate = latestMessage?.date {
//                                    DateTimeLabel(date: latestDate,
//                                                  font: .subheadline,
//                                                  colour: Color("text2"),
//                                                  mode: 2)
//                                    .padding(.trailing, 7.5)
                                    
                                } else {
                                    Text("-")
                                        .font(.caption)
                                        .foregroundColor(Color("text1"))
                                        .padding(.trailing, 10)
                                }
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 12)
                                    .foregroundColor(Color("blueAccent1"))
                            }
                            .padding(.bottom, 5)
                            
                            HStack(spacing: 0) {
                                Text(latestMessage?.message ?? "Tap to chat!")
                                    .font(.subheadline)
                                    .foregroundColor(Color("text2"))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2...2)
                                
                                Spacer()
                            }
                        }
                        .padding(.leading, 12.5)
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 13.5)
                    .padding(.trailing, 15)
                    .padding(.leading, 7.5)
                    
                    HStack(spacing: 0) {
                        Spacer()
                        
                        VStack(spacing: 0) {
                            Divider()
                                .frame(width: SP.screenWidth - 7.5 - 15 - 2.5 - 45 - 12.5)
                        }
                    }
                }
                .contextMenu() {
                    Button("Clear media", action: {
                        
                    })
                    
                    Button("Clear channel", action: {
                        if let RU = RU {
                            channelDC.deleteChannel(channel: channel,
                                                    remoteUser: RU) {_ in
                                Task {
                                    try await channelDC.syncChannels()
                                }
                            }
                        }
                    })
                    
                    Button("Delete channel", action: {
                        if let RU = RU {
                            channelDC.deleteChannel(channel: channel,
                                                    remoteUser: RU,
                                                    type: "delete") {_ in
                                Task {
                                    try await channelDC.syncChannels()
                                }
                            }
                        }
                    })
                    
                }
            }
        }
    }
    
    var username: some View {
        let usernameView = Text(RU?.username ?? "")
            .padding(.leading)
            .foregroundColor(Color.white)
        return usernameView
    }
    
    var onlineBadge: some View {
        guard let RU = RU else {
            return Text("-").foregroundColor(.white).fontWeight(.bold) }
        
        if let online = channelDC.onlineUsers[RU.userID],
           online == true {
            return Text("Online").foregroundColor(.green).fontWeight(.bold)
        } else {
            return Text("-").foregroundColor(.white).fontWeight(.bold)
        }
    }
}
