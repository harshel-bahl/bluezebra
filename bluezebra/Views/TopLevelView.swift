//
//  TopLevelView.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 22/01/2023.
//

import SwiftUI

struct TopLevelView: View {
    
    @EnvironmentObject var SP: ScreenProperties
    
    @ObservedObject var userDC = UserDC.shared
    @ObservedObject var channelDC = ChannelDC.shared
    @ObservedObject var messageDC = MessageDC.shared
    @ObservedObject var socketController = SocketController.shared
    
    @StateObject var styles = Styles()
    
    @State var fetchedUser = false
    
    @State var tab: String = "channels"
    
    var body: some View {
        ZStack {
            if (userDC.userData == nil || userDC.loggedIn != true) {
                
                ZStack {
                    if (fetchedUser == false) {
                        
                        Color("background2")
                        
                    } else if (fetchedUser == true && userDC.userData == nil) {
                        
                        SignUp()
                        
                    } else if (userDC.userData != nil && userDC.loggedIn == false) {
                        
                        Login()
                        
                    }
                }
                
            } else if (userDC.userData != nil && userDC.loggedIn == true) {
                
                topLevelTabView
                    .onAppear() {
                        if !userDC.userOnline {
                            socketController.userConnection()
                        }
                        
                        if (userDC.userSettings?.biometricSetup == nil) {
                            userDC.setupBiometricAuth()
                        }
                    }
            }
        }
        .sceneModifier(activeAction: {
            startup()
        }, inactiveAction: {
            prepareShutdown()
        }, backgroundAction: {
            shutdown()
        })
        .environmentObject(styles)
    }
    
    func startup() {
        Task {
            do {
                if userDC.userData == nil || userDC.userSettings == nil {
                    try await userDC.syncUserData()
                    try await userDC.syncUserSettings()
                }
                
                fetchedUser = true
                
                if userDC.userData != nil && userDC.userSettings != nil {
                    try await channelDC.syncAllData()
                }
                
                remoteConnection()
                
               try await messageDC.syncMessageDC()
            } catch {
                fetchedUser = true
                
                remoteConnection()
            }
        }
    }
    
    func remoteConnection() {
        if !socketController.connected {
            socketController.establishConnection()
        }
    }
    
    func prepareShutdown() {
        if userDC.userOnline {
            Task {
                await userDC.disconnectUser()
            }
        }
    }
    
    func shutdown() {
        SocketController.shared.closeConnection()
        userDC.loggedIn = false
    }
    
    var topLevelTabView: some View {
        TopLevelTabView(tabView: TabView1(tab: $tab,
                                          tabNames: ["channels",
                                                     "profile"],
                                          imageNames: ["message.circle",
                                                       "person.crop.circle"],
                                          selectedNames: ["message.circle.fill",
                                                          "person.crop.circle.fill"],
                                          selectedColour: Color("accent1"),
                                          unselectedColour:  Color("darkAccent1"),
                                          backgroundColour: Color("background3"),
                                          betweenPadding: SP.screenWidth*0.18),
                        tabContent: ["channels": {
            AnyView(
                ChannelsList()
            )},
                                     "profile": {
            AnyView(
                ProfileHome()
            )}],
                        notActiveBG: {
            Color("background2")
        },
                        topSafeBG: Color("background1"),
                        bottomSafeBG: Color("background3"),
                        tabContentBG: Color("background1"),
                        tab: $tab)
    }
}


