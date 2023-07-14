//
//  ChannelsList.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 07/01/2023.
//

import SwiftUI

struct ChannelsList: View {
    
    @ObservedObject var userDC = UserDC.shared
    @ObservedObject var channelDC = ChannelDC.shared
    @ObservedObject var messageDC = MessageDC.shared
    
    @EnvironmentObject var SP: ScreenProperties
    
    @State var showUserRequestsView = false
    @State var showDeletionLog = false
    
    @State var chatNavigation: String? = nil
    
    @State var textSize: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            
            banner
                .edgePadding(top: 10,
                             bottom: 10,
                             leading: 20,
                             trailing: 20)
            
            Divider()
            
            ScrollView() {
                LazyVStack(spacing: 0) {
                    
                    meChannel
                    
                    ForEach(channelDC.channels, id: \.channelID) { channel in
                        if let RUID = channel.userID,
                           let RU = channelDC.RUs[RUID] {
                            ChannelView(channel: channel,
                                        RU: RU)
                        }
                    }
                }
            }
            
        }
        .sheetModifier(isPresented: $showUserRequestsView,
                       BG: Color("background3")) {
            UserRequestsView(showUserRequestsView: $showUserRequestsView)
        }
        .sheet(isPresented: $showDeletionLog, content: {
            DeletionLog(channelType: "user")
        })
    }
    
    
    var banner: some View {
        HStack(alignment: .center, spacing: 0) {
            
            SystemIcon(systemName: "arrow.uturn.backward.circle",
                       size: .init(width: 25, height: 25),
                       colour: Color("accent1"),
                       BGColour: Color("background1"),
                       applyClip: true,
                       shadow: 1,
            buttonAction: {
                showDeletionLog.toggle()
            })
            
            Spacer()
            
            FixedText(text: "Channels",
                      colour: Color("text1"),
                      fontSize: 16,
                      fontWeight: .bold)
            
            Spacer()
            
            SystemIcon(systemName: "plus.circle",
                       size: .init(width: 25, height: 25),
                       colour: Color("accent1"),
                       BGColour: Color("background1"),
                       applyClip: true,
                       shadow: 1.15,
            buttonAction: {
                showUserRequestsView.toggle()
            })
        }
    }
    
    var meChannel: some View {
        ZStack {
            NavigationLink {
                ChatView(channel: channelDC.personalChannel!)
            } label: {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        
                        Color.clear
                        .frame(width: 15,
                               height: 0)
                        .padding(.trailing, 2.5)
                        
                        if let avatar = userDC.userData?.avatar {
                            EmojiIcon(avatar: avatar,
                                      size: .init(width: 45, height: 45),
                                      emojis: BZEmojiProvider1.shared.getAll(),
                                      buttonAction: { avatar in
                                
                            })
                        }
                        
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                
                                FixedText(text: "@" + userDC.userData!.username,
                                          colour: Color("accent1"),
                                          fontSize: 17,
                                          fontWeight: .bold)
                                
                                FixedText(text: "(Me)",
                                          colour: Color("orangeAccent1"),
                                          fontSize: 15,
                                          fontWeight: .regular,
                                          padding: EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
                                
                                Spacer()
                                
                                if let latestDate = messageDC.personalMessages.first?.date {
                                    DateTimeShor(date: latestDate,
                                                 fontSize: 15,
                                                 colour: Color("text2"))
                                } else {
                                    FixedText(text: "-",
                                              colour: Color("text1"),
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
                            
                            
                                FixedText(text: messageDC.personalMessages.first?.message ?? "Tap to chat!",
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
                    Button("Clear Media", action: {
                        
                    })
                    
                    Button("Clear Channel", action: {
                        
                    })
                    
                }
            }
            
        }
    }
}


