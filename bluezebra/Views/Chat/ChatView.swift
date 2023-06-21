//
//  ChatView.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 02/01/2023.
//

import SwiftUI
import Combine

struct ChatView: View {
    
    @ObservedObject var userDC = UserDC.shared
    @ObservedObject var channelDC = ChannelDC.shared
    @ObservedObject var messageDC = MessageDC.shared
    
    @EnvironmentObject var SP: ScreenProperties
    
    let channel: SChannel
    let remoteUser: SRemoteUser?
    
    private var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue }
                .map { $0.cgRectValue.height },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(SP.bottomSafeAreaInset) }
        ).eraseToAnyPublisher()
    }
    
    init(channel: SChannel,
         remoteUser: SRemoteUser?  = nil) {
        self.channel = channel
        self.remoteUser = remoteUser
    }
    
    var body: some View {
        ZStack() {
            
            Color("background1")
                .ignoresSafeArea(edges: .bottom)
            
            VStack(spacing: 0) {
                chatView()
                    .padding(.bottom, SP.safeAreaHeight*0.01)
                
                InputContainer(channel: channel)
            }
            .keyboardAwarePadding()
        }
        .ignoresSafeArea(edges: .bottom)
        .toolbar() {
            ToolbarItem(placement: .principal) {
                navigationBar
            }
        }
        .toolbarBackground(Color("background3"), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        // navigation title that represents number of unread messages in channel list
    }
    
    var navigationBar: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    
                    if let icon = getIcon(channelID: channel.channelID),
                       let image = BZEmojiProvider1.shared.getEmojiByName(name: icon) {
                        Text(image.value)
                            .font(.system(size: geometry.size.height*0.66))
                            .frame(height: geometry.size.height*0.66)
                            .onTapGesture {
                                // navigate to user profile
                            }
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: geometry.size.height*0.66)
                            .foregroundColor(Color("blueAccent1"))
                    }
                    
                    if let name = getName(channelID: channel.channelID) {
                        Text(name)
                            .font(.headline)
                            .foregroundColor(Color("text1"))
                            .fontWeight(.bold)
                            .padding(.leading, geometry.size.width*0.033)
                        
                        if channel.channelID == "personal" {
                            Text("(Me)")
                                .font(.subheadline)
                                .foregroundColor(Color("orangeAccent1"))
                                .fontWeight(.regular)
//                                .offset(y: -1)
                                .padding(.leading, SP.width*0.015)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.leading, geometry.size.width*0.05)
            }
            .frame(width: geometry.size.width,
                   height: geometry.size.height)
        }
    }
    
    func getIcon(channelID: String,
                 userID: String? = nil) -> String? {
        if channelID == "personal" {
            return userDC.userData?.avatar
        } else {
            return "" // handle user and team channels here
        }
    }
    
    func getName(channelID: String) -> String? {
        if channelID == "personal" {
            return userDC.userData?.username
        } else {
            return "" // handle user and team channels here
        }
    }
    
    func chatView() -> some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: true) {
                ScrollViewReader { proxy in
                    LazyVStack(spacing: 0) {
                        if self.channel.channelID == "personal" {
                            
                            personalMessages
                            
                        }
                    }
                    .frame(maxWidth: .infinity,
                           minHeight: geometry.size.height,
                           alignment: .bottom)
                    .onReceive(keyboardHeightPublisher) { height in
                        if height == SP.bottomSafeAreaInset {
                            if let latestMessage = messageDC.personalMessages.first {
                                proxy.scrollTo(latestMessage.messageID)
                            }
                        } else if height > SP.bottomSafeAreaInset {
                            if let latestMessage = messageDC.personalMessages.first {
                                DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                                    proxy.scrollTo(latestMessage.messageID)
                                }
                            }
                        }
                    }

                }
            }
            .background { Color("background1") }
        }
    }
    
    var personalMessages: some View {
        ForEach(messageDC.personalMessages.reversed(), id: \.messageID) { message in
            
            let showDateheader = shouldShowDateHeader(
                messages: messageDC.personalMessages.reversed(),
                thisMessage: message
            )
            
            if showDateheader {
                dateLabel(date: message.date)
            }
            
            messageCellContainer(channel: channel,
                                 message: message)
        }
    }
    
    func messageCellContainer(channel: SChannel, message: SMessage) -> some View {
        MessageContainer(channel: channel,
                         message: message)
        .id(message.messageID)
    }
    
    func shouldShowDateHeader(messages: [SMessage], thisMessage: SMessage) -> Bool {
        if let messageIndex = messages.firstIndex(where: { $0.messageID == thisMessage.messageID }) {
            if messageIndex == 0 { return true }
            
            let prevMessageDate = DataU.shared.dateDMY(date: messages[messageIndex].date)
            let currMessageDate = DataU.shared.dateDMY(date: messages[messageIndex - 1].date)
            
            if prevMessageDate == currMessageDate {
                return false
            } else {
                return true
            }
        }
        return false
    }
    
    func dateLabel(date: Date) -> some View {
        
        var dateText: String?
        
        if Calendar.current.isDateInToday(date) {
            dateText = "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            dateText = "Yesterday"
        } else {
            dateText = DataU.shared.dateDMY(date: date)
        }
        
        return Text(dateText ?? "-")
            .font(.subheadline)
            .foregroundColor(Color("text1"))
            .padding(5)
            .background() { Color("background3")}
            .cornerRadius(7.5)
            .padding(.top, 25)
            .padding(.bottom, 15)
    }
}
