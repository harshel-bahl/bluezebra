//
//  ProfileHome.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 07/01/2023.
//

import SwiftUI
import EmojiPicker

struct ProfileHome: View {
    
    @ObservedObject var userDC = UserDC.shared
    
    @EnvironmentObject var SP: ScreenProperties
    
    var profileTabs: [String] = ["Account",
                                 "Authentication",
                                 "Encryption",
                                 "Notifications",
                                 "Privacy Policy"]
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            banner
                .edgePadding(top: 10,
                             bottom: 10,
                             leading: 20,
                             trailing: 20)
            
            Divider()
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 0) {
                    
                    HStack(spacing: 0) {
                        
                        Spacer()
                        
                        EmojiIcon(avatar: userDC.userData!.avatar,
                                  size: .init(width: 90, height: 90),
                                  emojis: BZEmojiProvider1.shared.getAll())
                        
                        Spacer()
                    }
                    .edgePadding(bottom: 15)
                    
                    FixedText(text: "@" + userDC.userData!.username,
                              colour: Color("accent1"),
                              fontSize: 22.5,
                              fontWeight: .bold)
                    .edgePadding(bottom: 25)
                    
                    HStack(spacing: 0) {
                        FixedText(text: "Status: ",
                                  colour: Color("text2"),
                                  fontSize: 15)
                        .edgePadding(trailing: 5)
                        
                        if userDC.userOnline {
                            PulsatingCircle(size: .init(width: 9, height: 9),
                                            colour: Color.green,
                                            scaleRatio: 0.75,
                                            animationSpeed: 1.25,
                                            text: "connected",
                                            textColour: Color("text2"),
                                            fontSize: 15,
                                            padding: 5)
                        } else {
                            PulsatingCircle(size: .init(width: 8, height: 8),
                                            colour: Color.red,
                                            scaleRatio: 0.75,
                                            animationSpeed: 1.25,
                                            text: "connected",
                                            textColour: Color("text2"),
                                            fontSize: 15,
                                            padding: 5)
                        }
                        
                        Spacer()
                    }
                    .edgePadding(bottom: 12.5,
                                 leading: 15)
                    
                    HStack(spacing: 0) {
                        FixedText(text: "Last Online: ",
                                  colour: Color("text2"),
                                  fontSize: 15)
                        .edgePadding(trailing: 5)
                        
                        if let lastOnline = userDC.userData!.lastOnline {
                            DateTimeLong(date: lastOnline,
                                         fontSize: 15,
                                         colour: Color("text2"))
                        } else {
                            FixedText(text: "-",
                                      colour: Color("text2"),
                                      fontSize: 15)
                        }
                        
                        Spacer()
                    }
                    .edgePadding(bottom: 17.5,
                                 leading: 15)
                    
                    Divider()
                    
                    NavigationLink(destination: {
                        receiveProfileTab(tab: "Account")
                    }, label: {
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                FixedText(text: "Account",
                                          colour: Color("text1"),
                                          fontSize: 17)
                                
                                Spacer()
                                
                                SystemIcon(systemName: "chevron.right",
                                           size: .init(width: 12.5, height: 12.5),
                                           colour: Color("accent1"))
                            }
                            .edgePadding(top: 12.5, bottom: 12.5, leading: 15, trailing: 15)
                            
                            
                            Divider()
                        }
                    })
                    
                    NavigationLink(destination: {
                        receiveProfileTab(tab: "Authentication")
                    }, label: {
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                FixedText(text: "Authentication",
                                          colour: Color("text1"),
                                          fontSize: 17)
                                
                                Spacer()
                                
                                SystemIcon(systemName: "chevron.right",
                                           size: .init(width: 12.5, height: 12.5),
                                           colour: Color("accent1"))
                            }
                            .edgePadding(top: 12.5, bottom: 12.5, leading: 15, trailing: 15)
                            
                            
                            Divider()
                        }
                    })
                    
                    NavigationLink(destination: {
                        receiveProfileTab(tab: "Encryption")
                    }, label: {
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                FixedText(text: "Encryption",
                                          colour: Color("text1"),
                                          fontSize: 17)
                                
                                Spacer()
                                
                                SystemIcon(systemName: "chevron.right",
                                           size: .init(width: 12.5, height: 12.5),
                                           colour: Color("accent1"))
                            }
                            .edgePadding(top: 12.5, bottom: 12.5, leading: 15, trailing: 15)
                            
                            
                            Divider()
                        }
                    })
                    
                    NavigationLink(destination: {
                        receiveProfileTab(tab: "Notifications")
                    }, label: {
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                FixedText(text: "Notifications",
                                          colour: Color("text1"),
                                          fontSize: 17)
                                
                                Spacer()
                                
                                SystemIcon(systemName: "chevron.right",
                                           size: .init(width: 12.5, height: 12.5),
                                           colour: Color("accent1"))
                            }
                            .edgePadding(top: 12.5, bottom: 12.5, leading: 15, trailing: 15)
                            
                            
                            Divider()
                        }
                    })
                    
                    NavigationLink(destination: {
                        receiveProfileTab(tab: "Privacy Policy")
                    }, label: {
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                FixedText(text: "Privacy Policy",
                                          colour: Color("text1"),
                                          fontSize: 17)
                                
                                Spacer()
                                
                                SystemIcon(systemName: "chevron.right",
                                           size: .init(width: 12.5, height: 12.5),
                                           colour: Color("accent1"))
                            }
                            .edgePadding(top: 12.5, bottom: 12.5, leading: 15, trailing: 15)
                            
                            
                            Divider()
                        }
                    })
                    
                }
                .edgePadding(top: 20,
                             bottom: 20,
                             leading: 20,
                             trailing: 20)
                .background(Color("background3"))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .edgePadding(top: 20,
                             bottom: 20,
                             leading: 20,
                             trailing: 20)
            }
            .frame(maxHeight: .infinity)
        }
    }
    
    var banner: some View {
        HStack(alignment: .center, spacing: 0) {
            
            Spacer()
            
            FixedText(text: "Profile",
                      colour: Color("text1"),
                      fontSize: 16,
                      fontWeight: .bold)
            
            Spacer()
        }
        .frame(height: 25)
    }
    
    func receiveProfileTab(tab: String) -> some View {
        var view = AnyView(Color.black)
        
        switch(tab) {
        case "Account":
            view = AnyView(AccountTab())
        case "Authentication":
            view = AnyView(AuthenticationTab())
        case "Encryption":
            view = AnyView(EncryptionTab())
        case "Notifications":
            view = AnyView(NotificationsTab())
        case "Privacy Policy":
            view = AnyView(PrivacyPolicyTab())
        default: break
        }
        return view
    }
    
    
}
