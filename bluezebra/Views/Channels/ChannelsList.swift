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
                        .padding(.leading, SP.width*0.05)
                        .padding(.trailing, SP.width*0.05)
                        .padding(.bottom, 10)
                        .padding(.top, 12.5)
                    
                    Divider()
                    
                    
                    ScrollView {
                        
                        meChannel
                        
                        //                        ForEach(channelDC.userChannels, id: \.channelID) { channel in
                        //
                        //                            ChannelView(channel: channel)
                        //                                .listRowBackground(Color.black)
                        //                        }
                    }
                    .listStyle(.plain)
                    
                }
                .sheet(isPresented: $showUserRequestsView, content: {
                    UserRequestsView(showUserRequestsView: $showUserRequestsView)
                })
                .sheet(isPresented: $showDeletionLog, content: {
                    DeletionLog()
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
                            //                    Image(systemName: "circle.fill")
                            //                        .resizable()
                            //                        .aspectRatio(contentMode: .fit)
                            //                        .frame(maxWidth: SP.width*0.03)
                            //                        .foregroundColor(Color("blueAccent1"))
                        }
                        .frame(maxWidth: SP.width*0.03,
                               maxHeight: .infinity)
                        .padding(.trailing, SP.width*0.0175)
                        
                        if let avatar = userDC.userData?.avatar,
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
                                Text(userDC.userData!.username)
                                    .font(.headline)
                                    .foregroundColor(Color("text1"))
                                    .fontWeight(.bold)
                                
                                Text("(Me)")
                                    .font(.subheadline)
                                    .foregroundColor(Color("orangeAccent1"))
                                    .fontWeight(.regular)
                                    .offset(y: -1)
                                    .padding(.leading, SP.width*0.015)
                                
                                Spacer()
                                
                                if let latestDate = messageDC.personalMessages.first?.date {
                                    let time = DU.shared.extractedTime(date: latestDate)
                                    
                                    if Calendar.current.isDateInToday(latestDate) {
                                        Text("Today,")
                                            .font(.caption)
                                            .foregroundColor(Color("text1"))
                                        
                                        Text(time)
                                            .font(.caption)
                                            .foregroundColor(Color("text1"))
                                            .padding(.trailing, 10)
                                            .padding(.leading, 2.5)
                                    } else if Calendar.current.isDateInYesterday(latestDate) {
                                        Text("Yesterday,")
                                            .font(.caption)
                                            .foregroundColor(Color("text1"))
                                        
                                        Text(time)
                                            .font(.caption)
                                            .foregroundColor(Color("text1"))
                                            .padding(.trailing, 10)
                                            .padding(.leading, 2.5)
                                    } else {
                                        let date = DU.shared.extractedDate(date: latestDate)
                                        
                                        Text(date)
                                            .font(.caption)
                                            .foregroundColor(Color("text1"))
                                        
                                        Text(time)
                                            .font(.caption)
                                            .foregroundColor(Color("text1"))
                                            .padding(.trailing, 10)
                                            .padding(.leading, 2.5)
                                    }
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
                            
                            //                        Text("Subject: ")
                            //                            .font(.caption2)
                            //                            .foregroundColor(Color.gray)
                            //                            .lineLimit(1)
                            
                            HStack(spacing: 0) {
                                Text(messageDC.personalMessages.first?.message ?? "Tap to chat!")
                                    .font(.subheadline)
                                //                            .fontWeight(.regular) make bold for unread
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
            }
        }
    }
}


