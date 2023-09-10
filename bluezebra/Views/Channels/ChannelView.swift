//
//  ChannelView.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 07/02/2023.
//

import SwiftUI
import CoreData
import ScreenshotPreventingSwiftUI

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
        
        if channel.channelType != "personal" && RU != nil {
            self.channel = channel
            self.RU = RU
        } else if channel.channelType == "personal" {
            self.channel = channel
            self.RU = nil
        } else {
            return nil
        }
    }
    
    var body: some View {
        NavigationLink {
            
            if channel.channelType != "personal" {
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
                        
                        if channel.channelType != "personal",
                           let readReceipt = latestMessage?.read,
                           userDC.userdata!.uID.uuidString == readReceipt  {
                            SystemIcon(systemName: "circle.fill",
                                       size: .init(width: 7.5, height: 7.5),
                                       colour: Color("accent1"))
                        }
                    }
                    .frame(width: 15)
                    .edgePadding(trailing: 2.5)
                    
                    ZStack {
                        EmojiIcon(avatar: channel.channelType != "personal" ? RU!.avatar : userDC.userdata!.avatar,
                                  size: .init(width: 45, height: 45),
                                  emojis: BZEmojiProvider1.shared.getAll(),
                                  buttonAction: { avatar in
                            
                        })
                    }
                    
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            FixedText(text: "@" + (channel.channelType != "personal" ? RU!.username : userDC.userdata!.username),
                                      colour: Color("accent1"),
                                      fontSize: 17,
                                      fontWeight: .bold)
                            
                            if channel.channelType == "personal" {
                                FixedText(text: "(Me)",
                                          colour: Color("accent6"),
                                          fontSize: 12,
                                          fontWeight: .bold,
                                          padding: EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
                            }
                            
                            if channel.channelType != "personal",
                               let online = channelDC.onlineUsers[RU!.uID],
                               online == true {
                                
                                PulsatingCircle(size: .init(width: 10, height: 10),
                                                colour: .green,
                                                scaleRatio: 0.7,
                                                animationSpeed: 1.5)
                                .edgePadding(leading: 10)
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
                        
                            FixedText(text: {
                                if let latestMessage = self.latestMessage {
                                    if channel.channelType == "personal" && latestMessage.imageIDs != nil && latestMessage.message == "" {
                                        return "📷 Sent something"
                                    } else if latestMessage.imageIDs != nil && latestMessage.message == nil {
                                        return "📷 Sent you something!"
                                    } else if let message = latestMessage.message {
                                        return message
                                    } else {
                                        return ""
                                    }
                                } else {
                                    return "Tap to chat!"
                                }
                            }(),
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
            .onAppear() {
                if let latestMessage = messageDC.channelMessages[channel.channelID]?.first {
                    self.latestMessage = latestMessage
                }
            }
            .onChange(of: messageDC.channelMessages[channel.channelID]?.first, perform: { latestMessage in
                self.latestMessage = latestMessage
            })
            .contextMenu() {
                Button("Clear media", action: {
                    
                })
                
                Button("Clear channel", action: {
                    Task {
                        do {
                            if channel.channelType == "personal" {
//                                try await messageDC.clearChannelMessages(channelID: "personal")
                            } else {
                                if let RU = self.RU {
//                                    try await channelDC.sendCD(channel: self.channel,
//                                                               RU: RU)
                                }
                            }
                        } catch {
                        }
                    }
                })
                
                if channel.channelType != "personal" {
                    Button("Delete channel", action: {
                        Task {
                            do {
                                if channel.channelType == "personal" {
//                                    try await messageDC.deleteChannelMessages(channelID: "personal")
                                } else {
                                    if let RU = self.RU {
//                                        try await channelDC.sendCD(channel: self.channel,
//                                                                   RU: RU,
//                                                                   type: "delete")
                                    }
                                }
                            } catch {
                            }
                        }
                    })
                }
            }
        }
    }
}
