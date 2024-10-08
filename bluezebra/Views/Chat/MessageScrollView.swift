//
//  MessageScrollView.swift
//  bluezebra
//
//  Created by Harshel Bahl on 15/07/2023.
//

import SwiftUI
import Combine
import ScreenshotPreventingSwiftUI

struct MessageScrollView: View {
    
    @EnvironmentObject var chatState: ChatState
    
    @ObservedObject var messageDC = MessageDC.shared
    
//    @State var messages: [SMessage]?
    
    let BGColour: Color
    
    let dateFontSize: CGFloat
    let dateFontColour: Color
    let dateBG: Color
    let dateBorderPadding: CGFloat
    let datePadding: EdgeInsets
    
    let showDateHeaders: Bool
    
    let scrollAnimation: Animation
    let scrollOnUnfocus: Bool
    let scrollOnSizeChange: Bool
    
    @State var keyboardHeight: CGFloat = 0
    @State var scrollviewHeight: CGSize = .zero
    
    private var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
                .map { $0.height },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
        ).eraseToAnyPublisher()
    }
    
    init(BGColour: Color = Color("background1"),
         dateFontSize: CGFloat = 16,
         dateFontColour: Color = Color("text1"),
         dateBG: Color = Color("background5"),
         dateBorderPadding: CGFloat = 7,
         datePadding: EdgeInsets = .init(top: 20, leading: 0, bottom: 15, trailing: 0),
         showDateHeaders: Bool = true,
         scrollAnimation: Animation = .easeInOut(duration: 0.05),
         scrollOnUnfocus: Bool = false,
         scrollOnSizeChange: Bool = true) {
        self.BGColour = BGColour
        self.dateFontSize = dateFontSize
        self.dateFontColour = dateFontColour
        self.dateBG = dateBG
        self.dateBorderPadding = dateBorderPadding
        self.datePadding = datePadding
        self.showDateHeaders = showDateHeaders
        self.scrollAnimation = scrollAnimation
        self.scrollOnUnfocus = scrollOnUnfocus
        self.scrollOnSizeChange = scrollOnSizeChange
    }
    
    var body: some View {
        ChildSizeReader(size: $scrollviewHeight) {
            ZStack {
                BGColour
                
                GeometryReader { geo in
                    ScrollViewReader { proxy in
                        ScrollView(.vertical, showsIndicators: true) {
                            LazyVStack(spacing: 0) {
                                containers
                            }
                        }
                        .onAppear {
                            proxy.scrollTo(getMessages()?.last?.messageID, anchor: .bottom)
                            
//                            Task() {
//                                try? await chatState.fetchImages()
//                            }
                        }
                        .onChange(of: keyboardHeight, perform: { height in
                            if height == 0 {
                                if scrollOnUnfocus {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation(scrollAnimation) {
                                            proxy.scrollTo(getMessages()?.last?.messageID, anchor: .bottom)
                                        }
                                    }
                                }
                            } else if height > 0 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation(scrollAnimation) {
                                        proxy.scrollTo(getMessages()?.last?.messageID, anchor: .bottom)
                                    }
                                }
                            }
                        })
                        .onChange(of: scrollviewHeight, perform: { scrollviewSize in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                withAnimation(scrollAnimation) {
                                    proxy.scrollTo(getMessages()?.last?.messageID, anchor: .bottom)
                                }
                            }
                        })
                        .onChange(of: getMessages(), perform: { messages in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(scrollAnimation) {
                                    proxy.scrollTo(messages?.last?.messageID, anchor: .bottom)
                                }
                            }
                        })
                    }
                }
            }
            .ignoresSafeArea()
            .onReceive(keyboardHeightPublisher, perform: { height in
                keyboardHeight = height
            })
            .screenshotProtected(isProtected: true)
        }
    }
    
    @ViewBuilder
    var containers: some View {
        if let messages = getMessages() {
//            ScreenshotPrevent(isProtected: true) {
                ForEach(messages, id: \.messageID) { message in
                    
                    if showDateHeaders {
                        let showDateHeader = shouldShowDateHeader(
                            messages: messages,
                            thisMessage: message
                        )
                        
                        if let showDateHeader = showDateHeader,
                           showDateHeader {
                            DateDMY(date: message.date,
                                    fontSize: dateFontSize,
                                    colour: dateFontColour)
                            .padding(dateBorderPadding)
                            .background() { dateBG }
                            .cornerRadius(5)
                            .padding(messages.first?.messageID == message.messageID ?
                                     EdgeInsets(top: 10, leading: 0, bottom: 15, trailing: 0) : datePadding)
                        }
                    }
                    
                    let messageStatus = chatState.computeReceipt(message: message)
                    
                    MessageContainer(message: message,
                                     messageStatus: messageStatus)
                    .id(message.messageID)
                    .padding(.bottom, messages.last?.messageID == message.messageID ? 5 : 0)
//                    .screenshotProtected(isProtected: true)
                }
//            }
        }
    }
    
    func getMessages() -> [SMessage]? {
        if let messages = messageDC.channelMessages[chatState.currChannel.channelID]?.reversed() {
            return Array(messages)
        } else {
            return nil
        }
    }
    
    func shouldShowDateHeader(messages: [SMessage], thisMessage: SMessage) -> Bool? {
        if let messageIndex = messages.firstIndex(where: { $0.messageID == thisMessage.messageID }) {
            if messageIndex == 0 { return true }
            
            let prevMessageDate = DateU.shared.dateDMY(date: messages[messageIndex].date)
            let currMessageDate = DateU.shared.dateDMY(date: messages[messageIndex - 1].date)
            
            if prevMessageDate == currMessageDate {
                return false
            } else {
                return true
            }
        } else {
            return nil
        }
    }
}

