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
                localStartup()
                remoteConnection()
            case "inactive":
                prepareShutdown()
            case "background":
                shutdown()
            default: break
            }
        }
    }
    
    func localStartup() {
        if userDC.userData == nil {
            userDC.fetchUserData() { result in
                fetchedUser = true
                
                switch result {
                case .success(let userData):
                    userDC.userData = userData
                    
                    userDC.fetchUserSettings() { result in
                        switch result {
                        case .success(let userSettings):
                            userDC.userSettings = userSettings
                        case .failure(_):
                            // call function that generates settings if not present when userdata is present
                            break
                        }
                    }
                    
                    
                    Task {
                        await channelDC.fetchAllData()
                        try? await messageDC.syncPersonalChannel()
                    }
                case .failure(_): break
                }
            }
        } else {
            fetchedUser = true
            
            if userDC.userSettings == nil {
                userDC.fetchUserSettings() { result in
                    switch result {
                    case .success(let userSettings):
                        userDC.userSettings = userSettings
                    case .failure(_):
                        // call function that generates settings if not present when userdata is present
                        break
                    }
                }
            }
            
            // fetch channel DC data not present
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


