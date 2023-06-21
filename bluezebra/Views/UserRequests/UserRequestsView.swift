//
//  UserRequestsView.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 04/04/2023.
//

import SwiftUI

struct UserRequestsView: View {
    
    @Binding var showUserRequestsView: Bool
    
    @State var segment1 = 0
    @State var segment2 = 0
    
    @EnvironmentObject var SP: ScreenProperties
    
    @ObservedObject var userDC = UserDC.shared
    @ObservedObject var channelDC = ChannelDC.shared
    
    @ObservedObject var usernameTM = UsernameTextManager(limit: 13, text: "@")
    
    @State var fetchedUsers = [RUPacket]()
    
    @State var searchFailure = false
    
    @FocusState var usernameField: Bool
    
    var body: some View {
        ZStack {
            
            Color("background1")
                .ignoresSafeArea(edges: .bottom)
            
            VStack(spacing: 0) {
                
                Rectangle()
                    .fill(Color("darkAccent1").opacity(0.75))
                    .frame(width: SP.width*0.08, height: 5)
                    .cornerRadius(7.5)
                    .padding(.top, SP.safeAreaHeight*0.01)
                    .padding(.bottom, SP.safeAreaHeight*0.025)
                    .frame(width: SP.width)
                    .background() { Color("background3") }
                    
                Picker("", selection: $segment1) {
                    Text("Add Users")
                        .tag(0)
                    
                    Text("Requests")
                        .tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, SP.width*0.25)
                .padding(.bottom, SP.safeAreaHeight*0.025)
                .background() { Color("background3")}
                
                if segment1==0 {
                    addUser
                } else {
                    requestView
                }
            }
        }
    }
    
    var addUser: some View {
        VStack(spacing: 0) {
            
            UsernameTextField(textManager: usernameTM) { username in
                channelDC.fetchRUs(username: username) { (userDataList) in
                    switch userDataList {
                    case .success(let users):
                        fetchedUsers = users
                    case .failure(_): searchFailure = true
                    }
                }
            }
            .padding(.horizontal, SP.width*0.15)
            .padding(.bottom, SP.safeAreaHeight*0.025)
            .onAppear { usernameField.toggle() }
            .focused($usernameField)
            .background() { Color("background3") }
            
            ScrollView {
                ForEach(fetchedUsers, id: \.userID) { user in
                    
                    VStack(spacing: 0) {
                        AddUserRow(remoteUser: user)
                            .padding(.horizontal, SP.width*0.1)
                            .padding(.vertical, SP.safeAreaHeight*0.0225)
                        
                        Divider()
                    }
                }
            }
        }
        .onDisappear() {
            self.usernameTM.username = ""
            self.fetchedUsers = [RUPacket]()
        }
        .alert("Unable to search for users", isPresented: $searchFailure) {
            Button("Try again later", role: .cancel) {
                self.usernameTM.username = ""
            }
        }
    }
    
    var requestView: some View {
        VStack(spacing: 0) {
            
            HStack {
                Picker("", selection: $segment2) {
                    
                    Text("received")
                        .tag(0)
                    
                    Text("sent")
                        .tag(1)
                }
                .pickerStyle(.segmented)
                .frame(width: 125)
                
                Spacer()
            }
            .padding(.leading, 20)
            .padding(.vertical, 10)
            
            ScrollView {
                if segment2==0 {
                    ForEach(channelDC.channelRequests.filter({ $0.isSender==false }), id: \.channelID) { channelRequest in
                        
                        VStack(spacing: 0) {
                            ChannelRequestRow(channelRequest: channelRequest)
                                .padding(.horizontal, SP.width*0.1)
                                .padding(.vertical, SP.safeAreaHeight*0.0225)
                            
                            Divider()
                        }
                    }
                } else if segment2==1 {
                    ForEach(channelDC.channelRequests.filter({ $0.isSender==true }), id: \.channelID) { channelRequest in
                        
                        VStack(spacing: 0) {
                            ChannelRequestRow(channelRequest: channelRequest)
                                .padding(.horizontal, SP.width*0.1)
                                .padding(.vertical, SP.safeAreaHeight*0.0225)
                            
                            Divider()
                        }
                    }
                }
            }
        }
    }
}

