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
    
    @State var selectedEmoji: Emoji?
    @State var displayEmojiPicker = false
    
    var profileTabs: [String] = ["Account",
                                 "Chats",
                                 "Authentication",
                                 "Encryption",
                                 "Notifications",
                                 "Privacy Policy"]
    
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
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                
                                avatarButton
                                    .padding(.trailing, 22.5)
                                
                                if let username = userDC.userData?.username {
                                    Text("@" + username)
                                        .font(.title2)
                                        .foregroundColor(Color("blueAccent1"))
                                }
                                
                                Spacer()
                            }
                            .padding(.bottom, SP.safeAreaHeight*0.033)
                            
                            HStack(spacing: 0) {
                                
                                
                                Text("Last Online: ")
                                    .font(.subheadline)
                                    .fontWeight(.regular)
                                    .foregroundColor(Color("text2"))
                                
                                if let lastOnline = userDC.userData?.lastOnline {
                                    DateTimeLabel(date: lastOnline,
                                                  font: .subheadline,
                                                  colour: Color("text2"),
                                                  mode: 1)
                                } else {
                                    Text("-")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(Color("text2"))
                                }
                                
                                Spacer()
                            }
                            .padding(.bottom, SP.safeAreaHeight*0.02)
                            
                            Divider()
                            
                            ForEach(profileTabs, id: \.self) { tab in
                                
                                NavigationLink(destination: {
                                    receiveProfileTab(tab: tab)
                                }, label: {
                                    VStack(spacing: 0) {
                                        HStack(spacing: 0) {
                                            Text(tab)
                                                .font(.headline)
                                                .foregroundColor(Color("text1"))
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 10, height: 10)
                                        }
                                        
                                        .padding()
                                        
                                        Divider()
                                    }
                                })
                            }
                        }
                        .padding(.horizontal, SP.width*0.075)
                        .padding(.vertical, SP.safeAreaHeight*0.025)
                        .background(Color("background3"))
                        .cornerRadius(10)
                        .padding(.horizontal, SP.width*0.05)
                        .padding(.top, SP.safeAreaHeight*0.025)
                    }
                }
            }
        }
    }
    
    var banner: some View {
        HStack(alignment: .center, spacing: 0) {
            
            Spacer()
            
            Text("Profile")
                .font(.system(size: 16))
                .fontWeight(.bold)
                .foregroundColor(Color("text1"))
                .offset(x: -2.5)
            
            Spacer()
        }
        .frame(height: 25)
    }
    
    var avatarButton: some View {
        if let avatar = userDC.userData?.avatar,
           let emoji = BZEmojiProvider1.shared.getEmojiByName(name: avatar) {
            return AnyView(Text(emoji.value)
                .font(.system(size: SP.safeAreaHeight*0.06))
                .frame(width: SP.safeAreaHeight*0.06,
                       height: SP.safeAreaHeight*0.06)
                .onTapGesture {
                    // navigate to user profile
                })
        } else {
            return AnyView(Image(systemName: "person.crop.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: SP.safeAreaHeight*0.06,
                       height: SP.safeAreaHeight*0.06)
                .foregroundColor(Color("blueAccent1")))
        }
    }
    
    func receiveProfileTab(tab: String) -> some View {
        var view = AnyView(Color.black)
        
        switch(tab) {
        case "Account":
            view = AnyView(AccountTab())
        case "Chats":
            view = AnyView(ChatsTab())
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
