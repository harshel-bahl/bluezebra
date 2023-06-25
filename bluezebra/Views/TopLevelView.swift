//
//  TopLevelView.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 22/01/2023.
//

import SwiftUI

struct TopLevelView: View {
    
    @ObservedObject var userDC = UserDC.shared
    @ObservedObject var channelDC = ChannelDC.shared
    @ObservedObject var messageDC = MessageDC.shared
    @ObservedObject var socketController = SocketController.shared
    
    @StateObject var styles = Styles()
    
    @State var fetchedUser = false
    @Binding var scene: String
    
    var body: some View {
        VStack {
            if (userDC.userData == nil || userDC.loggedIn != true) {
                
                AuthenticationHome(fetchedUser: $fetchedUser,
                                   scene: $scene)
                
            } else if (userDC.userData != nil && userDC.loggedIn == true) {
                
                HomePage(scene: $scene)
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
        .environmentObject(styles)
        .onChange(of: scene) { phase in
            switch phase {
            case "active":
                startup()
            case "inactive":
                prepareShutdown()
            case "background":
                shutdown()
            default: break
            }
        }
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
}


