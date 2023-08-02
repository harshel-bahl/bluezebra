//
//  SignUp.swift
//  bluezebra
//
//  Created by Harshel Bahl on 06/07/2023.
//

import SwiftUI
import EmojiPicker

struct SignUp: View {
    
    @EnvironmentObject var SP: ScreenProperties
    
    @ObservedObject var userDC = UserDC.shared
    @ObservedObject var channelDC = ChannelDC.shared
    
    @State var selectedEmoji: Emoji?
    @State var  showEmojiPicker = false
    
    @State var username = ""
    @State var checkedUsername: Bool? = nil
    
    @State var pin: String = ""
    @State var firstPin: String = ""
    
    @FocusState var focusField: String?
    
    @State var createdUser = false
    @State var failure = false
    
    var body: some View {
        ZStack {
            PaginatedScrollView(backgroundColour: Color("background4"),
                                content: [
                                    ViewKey(id: 1): { proxy in
                                        AnyView(
                                            page1(proxy: proxy)
                                        )
                                    }, ViewKey(id: 2): { proxy in
                                        AnyView(
                                            page2(proxy: proxy)
                                        )
                                    }
                                ])
            
            if createdUser {
                ImageAni1(firstBGColour: Color("accent1"),
                          imageName: "checkmark.seal.fill",
                          secondImgColour: Color("accent1"))
            }
        }
    }
    
    func page1(proxy: ScrollViewProxy) -> some View {
        
        EmojiPicker(showEmojiPicker: $showEmojiPicker,
                    selectedEmoji: $selectedEmoji,
                    sheetHeight: SP.screenHeight/2,
                    emojiProvider: BZEmojiProvider1.shared) {
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    FixedText(text: "Create Profile",
                              colour: Color("text1"),
                              fontSize: 30,
                              fontWeight: .bold)
                    
                    Spacer()
                }
                .edgePadding(top: 25,
                             bottom: 15,
                             leading: 20,
                             trailing: 20)
                
                chooseAvatarBlock
                    .edgePadding(top: 15,
                                 bottom: 15,
                                 leading: 20,
                                 trailing: 20)
                
                ZStack {
                    if let _ = selectedEmoji {
                        chooseUsernameBlock(proxy: proxy)
                            .edgePadding(top: 15,
                                         leading: 20,
                                         trailing: 20)
                    }
                }
                .animation(.easeInOut(duration: 0.5).delay(0.15),
                           value: selectedEmoji)
                
                Spacer()
            }
        }
    }
    
    func page2(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                FixedText(text: "Secure Account",
                          colour: Color("text1"),
                          fontSize: 30,
                          fontWeight: .bold)
                
                Spacer()
                
                SystemIcon(systemName: "arrow.up.circle",
                           size: .init(width: 27.5, height: 27.5),
                           colour: Color("orangeAccent1"),
                           padding: .init(top: 0,
                                          leading: 0,
                                          bottom: 0,
                                          trailing: 5),
                           BGColour: .white,
                           applyClip: true,
                           shadow: 1,
                           buttonAction: {
                    
                    focusField = nil
                    
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.pin = ""
                        self.firstPin = ""
                        proxy.scrollTo(1, anchor: .top)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.51) {
                        focusField = "username"
                    }
                })
            }
            .edgePadding(top: 25,
                         bottom: 15,
                         leading: 20,
                         trailing: 20)
            
            
            pinEntry
                .edgePadding(top: 15,
                             leading: 20,
                             trailing: 20)
            
            signUpFlow
                .edgePadding(top: 30)
            
            Spacer()
        }
    }
    
    var chooseAvatarBlock: some View {
        ZStack {
            VStack(spacing: 27.5) {
                HStack(spacing: 0) {
                    VariableText(text: "Choose an avatar",
                                 colour: Color("text1"),
                                 font: .headline,
                                 fontWeight: .medium)
                    
                    Spacer()
                }
                
                avatarButton
            }
            .edgePadding(top: 17.5,
                         bottom: 17.5,
                         leading: 17.5,
                         trailing: 17.5)
        }
        .background() { Color("background2") }
        .borderModifier(lineWidth: 2,
                        lineColour: Color("accent1"),
                        cornerRadius: 20,
                        shadowRadius: 1)
    }
    
    @ViewBuilder
    var avatarButton: some View {
        if let selectedEmoji = selectedEmoji {
            EmojiIcon(avatar: selectedEmoji.name,
                      size: .init(width: 60, height: 60),
                      emojis: BZEmojiProvider1.shared.getAll(),
                      buttonAction: { avatar in
                showEmojiPicker = true
            })
        } else {
            SystemIcon(systemName: "person.crop.circle.fill",
                       size: .init(width: 60, height: 60),
                       colour: Color("accent1"),
                       padding: nil,
                       buttonAction: {
                showEmojiPicker = true
            })
        }
    }
    
    func chooseUsernameBlock(proxy: ScrollViewProxy) -> some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    VariableText(text: "Choose a username",
                                 colour: Color("text1"),
                                 font: .headline,
                                 fontWeight: .medium)
                    
                    Spacer()
                }
                
                HStack(alignment: .center, spacing: 25) {
                    usernameTextField(proxy: proxy)
                    
                    ZStack {
                        checkUsernameBadge
                    }
                    .frame(width: 25)
                }
                .edgePadding(top: 25)
                
                if let _ = checkedUsername,
                   checkedUsername == false {
                    HStack(spacing: 0) {
                        
                        Spacer()
                        
                        Text("Username unavailable :(")
                            .foregroundColor(Color("orangeAccent1"))
                            .fontWeight(.regular)
                        
                        Spacer()
                    }
                    .edgePadding(top: 12.5)
                }
            }
            .edgePadding(top: 17.5,
                         bottom: 17.5,
                         leading: 17.5,
                         trailing: 25)
        }
        .background() { Color("background2") }
        .borderModifier(lineWidth: 2,
                        lineColour: Color("accent1"),
                        cornerRadius: 20,
                        shadowRadius: 1)
        
    }
    
    func usernameTextField(proxy: ScrollViewProxy) -> some View {
        DebounceTextField(text: $username,
                          startingText: "@",
                          foregroundColour: Color("text3"),
                          font: .headline,
                          submitLabel: .go,
                          characterLimit: 13,
                          valuesToRemove: BZSetup.shared.removeUsernameValues,
                          autocorrection: false,
                          trimOnCommit: true,
                          replaceStartingOnCommit: true,
                          debouncedAction: { username in
            
            Task {
                do {
                    let result = try await userDC.checkUsername(username: username)
                    
                    withAnimation(.easeInOut(duration: 0.25)) {
                        self.checkedUsername = result
                    }
                } catch {
                    
                }
            }
        },
                          debounceFor: 0.5,
                          submitAction: { username in
            
            if let checkedUsername = checkedUsername,
               checkedUsername {
                withAnimation(.easeInOut(duration: 0.5)) {
                    proxy.scrollTo(2, anchor: .top)
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.51) {
                    focusField = "pin"
                }
            }
        })
        .focused($focusField, equals: "username")
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                focusField = "username"
            }
        }
    }
    
    @ViewBuilder
    var checkUsernameBadge: some View {
        if let _ = checkedUsername,
           checkedUsername == true {
            SystemIcon(systemName: "checkmark.seal.fill",
                       size: .init(width: 25,
                                   height: 25),
                       colour: Color("accent1"))
        } else if let _ = checkedUsername,
                  checkedUsername == false {
            SystemIcon(systemName: "exclamationmark.triangle.fill",
                       size: .init(width: 25,
                                   height: 25),
                       colour: Color("orangeAccent1"))
        }
    }
    
    var pinEntry: some View {
        ZStack {
            VStack(spacing: 17.5) {
                HStack(spacing: 0) {
                    VariableText(text: firstPin.count == 4 ? "Retype your pin" : "Create a pin",
                                 colour: Color("text1"),
                                 font: .headline,
                                 fontWeight: .medium)
                    
                    Spacer(minLength: 0)
                }
                
                HStack(spacing: 0) {
                    VariableText(text: "Pick something memorable! There's no other way to access your data",
                                 colour: Color("text1"),
                                 font: .subheadline)
                    
                    Spacer(minLength: 0)
                }
                
                PinBoxes(pin: $pin,
                         outerBorder: false,
                         focus: $focusField,
                         focusValue: "pin",
                         commitAction: { pin in
                    if firstPin == "" {
                        withAnimation {
                            firstPin = pin
                            self.pin = ""
                        }
                    } else if !firstPin.isEmpty {
                        focusField = nil
                    }
                })
                .edgePadding(top: 17.5)
            }
            .edgePadding(top: 17.5,
                         bottom: 17.5,
                         leading: 17.5,
                         trailing: 17.5)
        }
        .background() { Color("background2") }
        .borderModifier(lineWidth: 2,
                        lineColour: Color("accent1"),
                        cornerRadius: 20,
                        shadowRadius: 1)
    }
    
    @ViewBuilder
    var signUpFlow: some View {
        
        VStack(spacing: 15) {
            if firstPin==pin && firstPin.count==4 && pin.count==4 {
                ButtonAni(label: "Join BZ",
                          fontSize: 16,
                          foregroundColour: Color.white,
                          BGColour: Color("accent1"),
                          padding: 17.5,
                          action: {
                    
                    Task {
                        do {
                            let (userData, userSettings, personalChannel) = try await userDC.createUser(username: self.username,
                                                                                                        pin: pin,
                                                                                                        avatar: selectedEmoji!.name)
                            self.createdUser = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now()+2.75) {
                                userDC.userData = userData
                                userDC.userSettings = userSettings
                                channelDC.personalChannel = personalChannel
                                userDC.loggedIn = true
                            }
                        } catch {
                            self.failure = true
                        }
                    }
                })
            } else if firstPin != pin && firstPin.count==4 && pin.count==4 {
                FixedText(text: "Pin doesn't match :(",
                          colour: Color("orangeAccent1"),
                          fontSize: 14)
                
                ButtonAni(label: "Retry Pin",
                          fontSize: 16,
                          foregroundColour: Color.white,
                          BGColour: Color("orangeAccent1"),
                          padding: 17.5,
                          action: {
                    self.pin = ""
                    self.firstPin = ""
                })
            }
        }
        .animation(.easeInOut(duration: 0.35), value: pin)
    }
    
    
}

