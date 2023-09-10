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
    
    @State var username = ""
    @State var checkedUsername: Bool? = nil
    
    @State var selectedEmoji: Emoji?
    
    @State var pin: String = ""
    @State var firstPin: String = ""
    
    @FocusState var focusField: String?
    
    @State var createdUser = false
    @State var failure = false
    
    var body: some View {
        ZStack {
            PaginatedScrollView(backgroundColour: Color("background1"),
                                content: [
                                    ViewKey(id: 1): { proxy in
                                        AnyView(
                                            page1(proxy: proxy)
                                        )
                                    }, ViewKey(id: 2): { proxy in
                                        AnyView(
                                            page2(proxy: proxy)
                                        )
                                    },
                                    ViewKey(id: 3): { proxy in
                                        AnyView(
                                            page3(proxy: proxy)
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
        
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                FixedText(text: "Choose your username",
                          colour: Color("text1"),
                          fontSize: 28,
                          fontWeight: .bold)
                
                Spacer()
            }
            .edgePadding(top: 30,
                         bottom: 20,
                         leading: 20,
                         trailing: 20)
            
            
            VStack(spacing: 0) {
                
                ZStack {
                    usernameTextField(proxy: proxy)
                        .frame(width: 250)
                    
                    HStack(spacing: 0) {
                        if let checkedUsername = checkedUsername,
                           checkedUsername == true,
                           username != "" {
                            SystemIcon(systemName: "checkmark.seal.fill",
                                       size: .init(width: 27.5, height: 27.5),
                                       colour: Color("accent1"))
                            .edgePadding(leading: 310)
                        }
                    }
                }
                .edgePadding(top: 45,
                             bottom: 35)
                
                if let checkedUsername = checkedUsername,
                   checkedUsername == false,
                   username != "" {
                    HStack(spacing: 0) {
                        Spacer()
                        
                        FixedText(text: "Username Unavailable :(",
                                  colour: Color("accent6"),
                                  fontSize: 17.5,
                                  fontWeight: .regular)

                        Spacer()
                    }
                }
            }
            .edgePadding(top: 17.5,
                         bottom: 17.5,
                         leading: 17.5,
                         trailing: 25)
            
            Spacer()
        }
    }
    
    func usernameTextField(proxy: ScrollViewProxy) -> some View {
        DebounceTextField(text: $username,
                          startingText: "@",
                          foregroundColour: Color("accent1"),
                          font: .system(size: 25),
                          textFieldStyle: "plain",
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
                
                focusField = nil
                
                withAnimation(.easeInOut(duration: 0.5)) {
                    proxy.scrollTo(2, anchor: .top)
                }
            }
        })
        .focused($focusField, equals: "username")
        .padding(15)
        .background { Color("background3") }
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .overlay( RoundedRectangle(cornerRadius: 15) .stroke(Color("accent2")) )
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                focusField = "username"
            }
        }
    }
    
    func page2(proxy: ScrollViewProxy) -> some View {
        
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                FixedText(text: "Choose your avatar",
                          colour: Color("text1"),
                          fontSize: 28,
                          fontWeight: .bold)
                
                Spacer()
                
                SystemIcon(systemName: "arrow.up.circle",
                           size: .init(width: 27.5, height: 27.5),
                           colour: Color("accent1"),
                           padding: .init(top: 0,
                                          leading: 0,
                                          bottom: 0,
                                          trailing: 5),
                           BGColour: Color("background1"),
                           applyClip: true,
                           shadow: 1,
                           buttonAction: {
                    
                    withAnimation(.easeInOut(duration: 0.5)) {
                        proxy.scrollTo(1, anchor: .top)
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.51) {
                        focusField = "username"
                    }
                })
            }
            .edgePadding(top: 30,
                         bottom: 20,
                         leading: 20,
                         trailing: 20)
            
            EmojiGrid(emojis: BZEmojiProvider1.shared.getAll(),
                      selectedEmoji: $selectedEmoji)
            .edgePadding(top: 20, bottom: 25, leading: 0, trailing: 0)
            .frame(height: SP.safeAreaHeight*0.725)
            
            if let _ = selectedEmoji {
                
                SimpleButton(label: "continue",
                             fontSize: 18,
                             fontWeight: .bold,
                             buttonSize: .init(width: SP.screenWidth*0.75, height: 50),
                             cornerRadius: 10,
                             action: {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        proxy.scrollTo(3, anchor: .top)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        focusField = "pin"
                    }
                })
            }
            
            Spacer()
        }
    }
    
    func page3(proxy: ScrollViewProxy) -> some View {
        
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                FixedText(text: firstPin.count == 4 ? "Retype your pin" : "Create a pin",
                          colour: Color("text1"),
                          fontSize: 28,
                          fontWeight: .bold)
                
                Spacer()
                
                SystemIcon(systemName: "arrow.up.circle",
                           size: .init(width: 27.5, height: 27.5),
                           colour: Color("accent1"),
                           padding: .init(top: 0,
                                          leading: 0,
                                          bottom: 0,
                                          trailing: 5),
                           BGColour: Color("background1"),
                           applyClip: true,
                           shadow: 1,
                           buttonAction: {
                    
                    focusField = nil
                    pin = ""
                    firstPin = ""
                    
                    withAnimation(.easeInOut(duration: 0.5)) {
                        proxy.scrollTo(2, anchor: .top)
                    }
                })
            }
            .edgePadding(top: 30,
                         bottom: 25,
                         leading: 20,
                         trailing: 20)
            
            
            FixedText(text: "Pick something memorable! There's no other way to access your data",
                      colour: Color("text1"),
                      fontSize: 16,
                      pushText: .leading)
            .edgePadding(leading: 20,
                         trailing: 20)
            
            PinBoxes(pin: $pin,
                     outerBorder: true,
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
            .edgePadding(top: 50)
            
            signUpFlow
                .edgePadding(top: 50)
            
            Spacer()
        }
    }
    
    @ViewBuilder
    var signUpFlow: some View {
        
        VStack(spacing: 15) {
            if firstPin==pin && firstPin.count==4 && pin.count==4 {
                ButtonAni(label: "Join BZ",
                          fontSize: 18,
                          fontWeight: .bold,
                          foregroundColour: Color.white,
                          buttonSize: .init(width: SP.screenWidth*0.8, height: 50),
                          BGColour: Color("accent1"),
                          action: {
                    Task {
                        do {
                            let (userdata, userSettings, personalChannel) = try await userDC.createUser(username: self.username,
                                                                                                        pin: pin,
                                                                                                        avatar: selectedEmoji!.name)
                            self.createdUser = true
                            
                            DispatchQueue.main.asyncAfter(deadline: .now()+2.75) {
                                userDC.userdata = userdata
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
                ButtonAni(label: "Retry Pin",
                          fontSize: 18,
                          fontWeight: .bold,
                          foregroundColour: Color.white,
                          buttonSize: .init(width: SP.screenWidth*0.75, height: 50),
                          BGColour: Color("accent6"),
                          action: {
                    focusField = "pin"
                    self.pin = ""
                    self.firstPin = ""
                })
            }
        }
        .animation(.easeInOut(duration: 0.35), value: pin)
    }
    
    
}

