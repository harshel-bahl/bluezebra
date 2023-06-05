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
    
    var profileTabs: [String] = ["Account Actions",
                                 "Chats",
                                 "Authentication",
                                 "Encryption",
                                 "Notifications",
                                 "Prviacy Policy"]
    
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
                    
                    HStack(spacing: 0) {
                        
                    }
//                    Form {
//                        ForEach(profileTabs, id: \.self) { tab in
//
//                            NavigationLink(destination: {
//                                receiveProfileTab(tab: tab)
//                            }, label: {
//                                Text(tab)
//                                    .font(.headline)
//                                    .foregroundColor(Color("text1"))
//                            })
//                        }
//                    }
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
        Button(action: {
            displayEmojiPicker = true
        }) {
            if let selectedEmoji = selectedEmoji {
                Text(selectedEmoji.value)
                    .font(.system(size: SP.width*0.125))
                    .frame(height: SP.width*0.15)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: SP.width*0.15)
                    .foregroundColor(Color("blueAccent1"))
            }
        }
    }
    
    func receiveProfileTab(tab: String) -> some View {
        var view = AnyView(Color.black)
        
        switch(tab) {
        case "Account":
            view = AnyView(AccountTab())
        case "Security Features":
            view = AnyView(SecurityFeaturesTab())
        case "Privacy":
            view = AnyView(PrivacyTab())
        case "Notifications":
            view = AnyView(NotificationsTab())
        case "Chats":
            view = AnyView(ChatsTab())
        case "Media":
            view = AnyView(MediaTab())
        case "Help":
            view = AnyView(HelpTab())
        default: break
        }
        return view
    }
}
