//
//  ChatInterface.swift
//  bluezebra
//
//  Created by Harshel Bahl on 15/07/2023.
//

import SwiftUI
import Combine

struct ChatInterface: View {
    
    @ObservedObject var userDC = UserDC.shared
    @ObservedObject var channelDC = ChannelDC.shared
    @ObservedObject var messageDC = MessageDC.shared
    
    @StateObject var chatState: ChatState
    
    let channelType: ChannelType
    let channel: SChannel
    let RU: SRemoteUser?
    
    enum ChannelType {
        case personal
        case RU
    }
    
    @FocusState var focusedField: String?
    
    init(channelType: ChannelType = .RU,
         channel: SChannel,
         RU: SRemoteUser) {
        self._chatState = StateObject(wrappedValue: ChatState(currChannel: channel,
                                                              currRU: RU))
        self.channelType = channelType
        self.channel = channel
        self.RU = RU
    }
    
    init(channelType: ChannelType = .personal,
         channel: SChannel) {
        self._chatState = StateObject(wrappedValue: ChatState(currChannel: channel))
        self.channelType = channelType
        self.channel = channel
        self.RU = nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NavBar() {
                EmojiIcon(avatar: getAvatar(),
                          size: .init(width: 32.5, height: 32.5),
                          emojis: BZEmojiProvider1.shared.getAll()) { avatar in }
                    .edgePadding(trailing: 10)
                
                FixedText(text: "@" + getName(),
                          colour: Color("accent1"),
                          fontSize: 17.5,
                          fontWeight: .bold)
                
                if channelType == .personal {
                    FixedText(text: "(Me)",
                              colour: Color("accent6"),
                              fontSize: 11,
                              fontWeight: .bold,
                              padding: EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0))
                }
                
                if channelType == .RU {
                    if channelDC.onlineUsers[RU!.userID] == true {
                        PulsatingCircle(text: "online",
                                        textColour: Color("text1"))
                        .edgePadding(leading: 10)
                    }
                }
                
                Spacer()
            }
            
            MessageScrollView()
                .onTapGesture {
                    focusedField = nil
                }
            
            InputContainer(focusedField: _focusedField)
        }
        .background() { Color("background1") }
        .ignoresSafeArea(edges: .top)
        .environmentObject(chatState)
    }
    
    func getAvatar() -> String {
        switch self.channelType {
        case .personal:
            return userDC.userData!.avatar
        case .RU:
            return RU!.avatar
        }
    }
    
    func getName() -> String {
        switch self.channelType {
        case .personal:
            return userDC.userData!.username
        case .RU:
            return RU!.username
        }
    }
    
}

