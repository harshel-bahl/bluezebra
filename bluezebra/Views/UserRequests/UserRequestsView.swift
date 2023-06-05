//
//  UserRequestsView.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 04/04/2023.
//

import SwiftUI

struct UserRequestsView: View {
    
    @Binding var showUserRequestsView: Bool
    
    @State var segment = 0
    
    @EnvironmentObject var SP: ScreenProperties
    
    @ObservedObject var userDC = UserDC.shared
    @ObservedObject var channelDC = ChannelDC.shared
    
    @ObservedObject var usernameTextManager = TextBindingManager(limit: 13)
    
    @State var fetchedUsers = [RemoteUserPacket]()
    
    @State var searchFailure = false
    
    @FocusState var usernameField: Bool
    
    var body: some View {
        ZStack {
            
            Color("background3")
                .ignoresSafeArea(edges: .bottom)
            
            VStack(spacing: 0) {
                
                Rectangle()
                    .fill(Color("darkAccent1").opacity(0.75))
                    .frame(width: SP.width*0.08, height: 5)
                    .cornerRadius(7.5)
                    .padding(.top, SP.safeAreaHeight*0.01)
                    .padding(.bottom, SP.safeAreaHeight*0.025)
                    
                Picker("", selection: $segment) {
                    Text("Add Users")
                        .tag(0)
                    
                    Text("Requests")
                        .tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, SP.width*0.2)
                .padding(.bottom, SP.safeAreaHeight*0.025)
                
                if segment==0 {
                    addUser
                } else {
                    requestView
                }
            }
        }
    }
    
    var addUser: some View {
        VStack(spacing: 0) {
            
            UsernameTextField { username in
                channelDC.fetchRemoteUser(userID: nil, username: username) { (userDataList) in
                    switch userDataList {
                    case .success(let users):
                        fetchedUsers = users
                    case .failure(_): searchFailure = true
                    }
                }
            }
            .padding(.horizontal, SP.width*0.1)
            .padding(.bottom, SP.safeAreaHeight*0.025)
            .onAppear { usernameField.toggle() }
            .focused($usernameField)
            
            ScrollView {
                ForEach(fetchedUsers, id: \.userID) { user in
//                    AddUserRow(remoteUser: user)
                    Text("hello")
                }
            }
            .listStyle(.plain)
        }
        .onDisappear() {
            self.usernameTextManager.username = ""
        }
        .alert("Unable to search for users", isPresented: $searchFailure) {
            Button("Try again later", role: .cancel) {
                self.usernameTextManager.username = ""
            }
        }
    }
    
    var requestView: some View {
        VStack(spacing: 0) {
            ScrollView {
                ForEach(channelDC.channelRequests, id: \.channelID) { channelRequest in
                    ChannelRequestRow(channelRequest: channelRequest)
                }
            }
            .listStyle(.plain)
        }
    }
}

