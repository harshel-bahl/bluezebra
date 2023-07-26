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
    let RU: SRemoteUser?
    @State var latestMessage: SMessage?
    
    @State var showChat = false
    
    @State var scale: CGFloat = 1
    
    init?(channel: SChannel,
         RU: SRemoteUser? = nil) {
        
        if channel.channelID != "personal" && RU != nil {
            self.channel = channel
            self.RU = RU
        } else if channel.channelID == "personal" {
            self.channel = channel
            self.RU = nil
        } else {
            return nil
        }
        
        if let latestMessage = messageDC.channelMessages[channel.channelID]?.first {
            self._latestMessage = State(wrappedValue: latestMessage)
        } else {
            latestMessage = nil
        }
    }
    
    var body: some View {
        NavigationLink {
            
            if channel.channelID != "personal" {
                ChatInterface(channelType: .RU,
                              channel: self.channel,
                              RU: self.RU!)
            } else {
                ChatInterface(channelType: .personal,
                              channel: channelDC.personalChannel!)
            }
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        
                        if channel.channelID != "personal",
                           let readReceipt = latestMessage?.read,
                           userDC.userData!.userID == readReceipt  {
                            SystemIcon(systemName: "circle.fill",
                                       size: .init(width: 7.5, height: 7.5),
                                       colour: Color("accent1"))
                        }
                    }
                    .frame(width: 15)
                    .edgePadding(trailing: 2.5)
                    
                    ZStack {
                        EmojiIcon(avatar: channel.channelID != "personal" ? RU!.avatar : userDC.userData!.avatar,
                                  size: .init(width: 45, height: 45),
                                  emojis: BZEmojiProvider1.shared.getAll(),
                                  buttonAction: { avatar in
                            
                        })
                        
                        if channel.channelID != "personal",
                           let online = channelDC.onlineUsers[RU!.userID],
                           online == true {
                            
                            PulsatingCircle(size: .init(width: 8, height: 8),
                                            colour: .green,
                                            scaleRatio: 0.75,
                                            animationSpeed: 0.5,
                                            text: "online",
                                            fontSize: 10,
                                            padding: 3)
                            .offset(y: 35)
                        }
                    }
                    
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            FixedText(text: "@" + (channel.channelID != "personal" ? RU!.username : userDC.userData!.username),
                                      colour: Color("accent1"),
                                      fontSize: 17,
                                      fontWeight: .bold)
                            
                            if channel.channelID == "personal" {
                                FixedText(text: "(Me)",
                                          colour: Color("orangeAccent1"),
                                          fontSize: 12,
                                          fontWeight: .bold,
                                          padding: EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
                            }
                            
                            Spacer()
                            
                            if let latestDate = latestMessage?.date {
                                DateTimeShor(date: latestDate,
                                             fontSize: 15,
                                             colour: Color("text2"))
                            } else {
                                FixedText(text: "-",
                                          colour: Color("text2"),
                                          fontSize: 15)
                            }
                            
                            SystemIcon(systemName: "chevron.right",
                                       size: .init(width: 8, height: 12.5),
                                       colour: Color("accent1"),
                                       padding: .init(top: 0,
                                                      leading: 10,
                                                      bottom: 0,
                                                      trailing: 0))
                        }
                        .edgePadding(bottom: 5)
                        
                        FixedText(text: latestMessage?.message ?? "Tap to chat!",
                                  colour: Color("text2"),
                                  fontSize: 15,
                                  lineLimit: 2...2,
                                  padding: EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8),
                                  multilineAlignment: .leading,
                                  pushText: .leading)
                    }
                    .edgePadding(leading: 12.5)
                }
                .edgePadding(top: 15,
                             bottom: 13.5,
                             leading: 7.5,
                             trailing: 15)
                
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
                    Task {
                        try await channelDC.clearChannelData(channelID: channel.channelID,
                                                         RU: RU ?? nil)
                    }
                })
                
                if channel.channelID != "personal" {
                    Button("Delete channel", action: {
                        Task {
                            try await channelDC.deleteChannelData(channelID: channel.channelID,
                                                                  RU: RU!)
                        }
                        
                    })
                }
            }
        }
    }
}
