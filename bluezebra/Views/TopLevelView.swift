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
    
    @State var fetchedUser = false
    
    @State var emittedPendingEvents = false
    
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
                .onAppear { tab = "channels" }
                
            } else if (userDC.userData != nil && userDC.loggedIn == true) {
                
                topLevelTabView
                    .onAppear() {
                        if !userDC.userOnline && socketController.connected {
                            userConnection()
                        }
                        
                        if (userDC.userSettings?.biometricSetup == nil) {
                            userDC.setupBiometricAuth() { result in
                                switch result {
                                case .success(): break
                                case .failure(let err):
#if DEBUG
                                    DataU.shared.handleFailure(function: "UserDC.setupBiometricAuth", err: err)
#endif
                                }
                            }
                        }
                    }
            }
        }
        .sceneModifier(activeAction: {
            startup()
        }, inactiveAction: {
            if userDC.userOnline {
                prepareShutdown()
            }
        }, backgroundAction: {
            shutdown()
        })
        .onChange(of: SocketController.shared.connected, perform: { connected in
            
            if connected && !userDC.userOnline && userDC.userData != nil {
                userConnection()
            }
            
            if !connected {
                userDC.offline()
                channelDC.offline()
            }
        })
        .onChange(of: userDC.userOnline, perform: { userOnline in
            
        })
        .onChange(of: userDC.emittedPendingEvents, perform: { emittedPendingEvents in
            if emittedPendingEvents {
                if channelDC.RUChannels.count != 0 {
                    startupNetworking()
                }
            }
        })
    }
    
    func startup() {
        Task {
            do {
                if userDC.userData == nil || userDC.userSettings == nil {
                    try await userDC.syncUserData()
                    try await userDC.syncUserSettings()
                }
                
                fetchedUser = true
                
                try await channelDC.syncAllData()
                
                if !socketController.connected {
                    socketController.establishConnection()
                }
                
                try await messageDC.syncMessageDC()
            } catch {
                fetchedUser = true
                
                if !socketController.connected {
                    socketController.establishConnection()
                }
            }
        }
    }
    
    func userConnection() {
        Task {
            do {
                try await userDC.connectUser()
                
            } catch {
            }
        }
    }
    
    func startupNetworking() {
        Task {
            do {
//                try await channelDC.checkChannelUsers()
                
            } catch {
            }
        }
    }
    
    func prepareShutdown() {
        Task {
            do {
//                try await userDC.disconnectUser()
                
            } catch {
            }
        }
    }
    
    func shutdown() {
        if socketController.connected { SocketController.shared.closeConnection() }
        userDC.shutdown()
        channelDC.shutdown()
        messageDC.shutdown()
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
                                          unselectedColour:  Color("accent5"),
                                          backgroundColour: Color("background3"),
                                          betweenPadding: 75),
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


