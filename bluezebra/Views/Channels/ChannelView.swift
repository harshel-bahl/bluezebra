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
        
        if let latestMessage = messageDC.userMessages[channel.channelID]?.first {
            self.latestMessage = latestMessage
        }
    }
    
    var body: some View {
        ZStack {
            NavigationLink {
                ChatView(channel: channel)
            } label: {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        VStack(spacing: 0) {
                            
                            if let readReceipt = latestMessage?.read,
                               userDC.userData!.userID == readReceipt  {
                                Image(systemName: "circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: SP.width*0.03)
                                    .foregroundColor(Color("blueAccent1"))
                            }
                        }
                        .frame(maxWidth: SP.width*0.03,
                               maxHeight: .infinity)
                        .padding(.trailing, SP.width*0.0175)
                        
                        if let avatar = remoteUser?.avatar,
                           let emoji = BZEmojiProvider1.shared.getEmojiByName(name: avatar) {
                            Text(emoji.value)
                                .font(.system(size: SP.safeAreaHeight*0.06))
                                .frame(width: SP.safeAreaHeight*0.06,
                                       height: SP.safeAreaHeight*0.06)
                                .onTapGesture {
                                    // navigate to user profile
                                }
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: SP.safeAreaHeight*0.06,
                                       height: SP.safeAreaHeight*0.06)
                                .foregroundColor(Color("blueAccent1"))
                        }
                        
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                if let remoteUser = remoteUser {
                                    Text(remoteUser.username)
                                        .font(.headline)
                                        .foregroundColor(Color("text1"))
                                        .fontWeight(.bold)
                                } else {
                                    Text("-")
                                        .font(.headline)
                                        .foregroundColor(Color("text1"))
                                        .fontWeight(.bold)
                                }
                                
                                Spacer()
                                
                                if let latestDate = latestMessage?.date {
                                    DateTimeLabel(date: latestDate,
                                                  font: .subheadline,
                                                  colour: Color("text2"),
                                                  mode: 2)
                                    .padding(.trailing, 7.5)
                                    
                                } else {
                                    Text("-")
                                        .font(.caption)
                                        .foregroundColor(Color("text1"))
                                        .padding(.trailing, 10)
                                }
                                
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: SP.safeAreaHeight*0.015)
                                    .foregroundColor(Color("blueAccent1"))
                            }
                            .padding(.bottom, SP.safeAreaHeight*0.005)
                            
                            HStack(spacing: 0) {
                                Text(latestMessage?.message ?? "Tap to chat!")
                                    .font(.subheadline)
                                    .foregroundColor(Color("text2"))
                                    .multilineTextAlignment(.leading)
                                    .lineLimit(2...2)
                                
                                Spacer()
                            }
                        }
                        .padding(.leading, SP.width*0.033)
                    }
                    .padding(.top, SP.safeAreaHeight*0.0225)
                    .padding(.bottom, SP.safeAreaHeight*0.0225)
                    .padding(.trailing, SP.width*0.05)
                    .padding(.leading, SP.width*0.02)
                    
                    HStack {
                        Spacer()
                        
                        VStack {
                            Divider()
                                .frame(width: SP.width - SP.width*0.03 - SP.width*0.02 - SP.width*0.02 - SP.safeAreaHeight*0.06 - SP.width*0.033)
                        }
                    }
                }
                .contextMenu() {
                    Button("Clear media", action: {
                        
                    })
                    
                    Button("Clear channel", action: {
                        
                    })
                    
                    Button("Delete channel", action: {
                        
                    })
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
    }
    
    var username: some View {
        let usernameView = Text(remoteUser?.username ?? "")
            .padding(.leading)
            .foregroundColor(Color.white)
        return usernameView
    }
    
    var onlineBadge: some View {
        guard let remoteUser = remoteUser else {
            return Text("-").foregroundColor(.white).fontWeight(.bold) }
        
        if let online = channelDC.onlineUsers[remoteUser.userID],
           online == true {
            return Text("Online").foregroundColor(.green).fontWeight(.bold)
        } else {
            return Text("-").foregroundColor(.white).fontWeight(.bold)
        }
    }
}
