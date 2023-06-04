//
//  ProfileHome.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 07/01/2023.
//

import SwiftUI

struct ProfileHome: View {
    
    @ObservedObject var userDC = UserDC.shared
    
    @EnvironmentObject var SP: ScreenProperties
    
    var profileTabs: [String] = ["Account",
                                 "Security Features",
                                 "Privacy",
                                 "Notifications",
                                 "Chats",
                                 "Media",
                                 "Help"]
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack {
                
                Color("background1")
                
                VStack(spacing: 0) {
                    
                    VStack(spacing: 0) {
                        
                        Spacer()
                        
                        banner
                    }
                    .padding(.leading, SP.width*0.05)
                    .padding(.trailing, SP.width*0.05)
                    .frame(height: getBannerHeight(geometryHeight: geometry.size.height))
                    
                    Divider()
                    
                    List() {
                        ForEach(profileTabs, id: \.self) { tab in

                            NavigationLink(destination: {
                                receiveProfileTab(tab: tab)
                            }, label: {
                                Text(tab)
                                    .font(.headline)
                                    .foregroundColor(Color("text1"))
                            })
                            .listRowBackground(Color.clear)
                        }
                    }
                    .listStyle(.plain)
                }
            }
        }
    }
    
    func getBannerHeight(geometryHeight: CGFloat,
                         type: String? = "banner") -> CGFloat {
        if SP.topSafeAreaInset/SP.safeAreaHeight > 0.05 {
            if type=="banner" {
                return geometryHeight*0.065
            } else {
                return geometryHeight*0.935
            }
        } else {
            if type=="banner" {
                return geometryHeight*0.08
            } else {
                return geometryHeight*0.92
            }
        }
    }
    
    var banner: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(alignment: .center, spacing: 0) {
                    
                    Spacer()
                    
                    Text("Profile")
                        .font(.system(size: geometry.size.height*0.425))
                        .frame(height: geometry.size.height*0.425)
                        .fontWeight(.bold)
                        .foregroundColor(Color("text1"))
                    
                    Spacer()
                }
            }
            .frame(width: geometry.size.width,
                   height: geometry.size.height)
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
