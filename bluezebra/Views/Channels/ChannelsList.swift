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
        GeometryReader { geometry in
            ZStack {
                
                Color("background1")
                
                VStack(spacing: 0) {
                    
                    banner
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(.bottom, 10)
                        .padding(.top, 12.5)
                    
                    Divider()
                    
                    
                    ScrollView() {
                        LazyVStack(spacing: 0) {
                            
                            meChannel
                            
                            ForEach(channelDC.channels, id: \.channelID) { channel in
                                ChannelView(channel: channel)
                            }
                        }
                    }
                    
                }
                .sheet(isPresented: $showUserRequestsView, content: {
                    UserRequestsView(showUserRequestsView: $showUserRequestsView)
                })
                .sheet(isPresented: $showDeletionLog, content: {
                    DeletionLog(channelType: "user")
                })
                
            }
            .ignoresSafeArea(.keyboard)
        }
    }
    
    var banner: some View {
        HStack(alignment: .center, spacing: 0) {
            
            Button(action: { showDeletionLog.toggle() }, label: {
                Image(systemName: "arrow.uturn.backward.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color("blueAccent1"))
            })
            
            Spacer()
            
            Text("Channels")
                .font(.system(size: 16))
                .fontWeight(.bold)
                .foregroundColor(Color("text1"))
            
            Spacer()
            
            Button(action: { showUserRequestsView.toggle() }, label: {
                Image(systemName: "plus.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color("blueAccent1"))
            })
        }
        .frame(height: 25)
    }
    
    var meChannel: some View {
        ZStack {
            NavigationLink {
                ChatView(channel: channelDC.personalChannel!)
            } label: {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        VStack(spacing: 0) {
                            
                        }
                        .frame(width: 15)
                        .padding(.trailing, 2.5)
                        
//                        if let avatar = userDC.userData?.avatar,
//                           let emoji = BZEmojiProvider1.shared.getEmojiByName(name: avatar) {
//                            Text(emoji.value)
//                                .font(.system(size: 45))
//                                .frame(width: 45,
//                                       height: 45)
//                        } else {
//                            Image(systemName: "person.crop.circle.fill")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 45,
//                                       height: 45)
//                                .foregroundColor(Color("blueAccent1"))
//                        }
                        
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Text("@" + userDC.userData!.username)
                                    .font(.headline)
                                    .foregroundColor(Color("blueAccent1"))
                                
                                Text("(Me)")
                                    .font(.subheadline)
                                    .foregroundColor(Color("orangeAccent1"))
                                    .fontWeight(.regular)
                                    .offset(y: -1)
                                    .padding(.leading, 5)
                                
                                Spacer()
                                
                                if let latestDate = messageDC.personalMessages.first?.date {
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
                                    .frame(height: 12)
                                    .foregroundColor(Color("blueAccent1"))
                            }
                            .padding(.bottom, 5)
                            
                            //                        Text("Subject: ")
                            //                            .font(.caption2)
                            //                            .foregroundColor(Color.gray)
                            //                            .lineLimit(1)
                            
                            HStack(spacing: 0) {
                                Text(messageDC.personalMessages.first?.message ?? "Tap to chat!")
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
                    Button("Clear Media", action: {
                        
                    })
                    
                    Button("Clear Channel", action: {
                        
                    })

                }
            }
            
        }
    }
}


