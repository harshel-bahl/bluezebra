//
//  UserRequestsView.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 04/04/2023.
//

import SwiftUI

struct UserRequestsView: View {
    
    @EnvironmentObject var SP: ScreenProperties
    
    @ObservedObject var userDC = UserDC.shared
    @ObservedObject var channelDC = ChannelDC.shared
    
    @Binding var showUserRequestsView: Bool
    
    @State var selected1: Int = 0
    @State var selected2: Int = 0
    
    @State var username = ""
    @FocusState var focusField: String?
    @State var fetchedUsers = [RUPacket]()
    @State var searchFailure = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            TextSegmentView(selected: $selected1,
                            textNames: ["Add Users", "Requests"],
                            BGColour: Color("accent2"),
                            selectedBGColour: Color("accent1"))
            .edgePadding(bottom: 25)
            
            if selected1 == 0 {
                addUserView
            } else if selected1 == 1 {
                requestView
            }
        }
        .ignoresSafeArea()
        .onChange(of: selected1, perform: { selected1 in
            if selected1 != 0 {
                focusField = nil
                self.username = ""
                self.fetchedUsers = [RUPacket]()
            }
        })
    }
    
    var addUserView: some View {
        VStack(spacing: 0) {
            
            usernameTextField()
                .frame(width: 250)
                .edgePadding(bottom: 10)
                .frame(width: SP.screenWidth)
                .background() { Color("background3") }
            
            ZStack {
                
                Color("background1")
                
                ScrollView {
                    ForEach(fetchedUsers, id: \.userID) { user in
                        
                        VStack(spacing: 0) {
                            AddUserRow(remoteUser: user)
                                .edgePadding(top: 15,
                                             bottom: 15,
                                             leading: 20,
                                             trailing: 20)
                            
                            Divider()
                        }
                    }
                }
            }
        }
        .keyboardAwarePadding()
    }
    
    func usernameTextField() -> some View {
        DebounceTextField(text: $username,
                          startingText: "@",
                          foregroundColour: Color("text3"),
                          font: .headline,
                          characterLimit: 13,
                          valuesToRemove: BZSetup.shared.removeUsernameValues,
                          autocorrection: false,
                          trimOnCommit: true,
                          replaceStartingOnCommit: true,
                          debouncedAction: { username in
            
            channelDC.fetchRUs(username: username) { result in
                switch result {
                case .success(let packets):
                    fetchedUsers = packets
                case .failure(_): break
                }
            }
            
        },
                          debounceFor: 0.4)
        .focused($focusField, equals: "username")
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                focusField = "username"
            }
        }
    }

    
    var requestView: some View {
        VStack(spacing: 0) {
            
            HStack {
                SimpleSegmentAni(selected: $selected2,
                                 textNames: ["received", "sent"],
                                 BGColour: Color("accent2"),
                                 selectedBGColour: Color("accent1"))
                
                Spacer()
            }
            .edgePadding(top: 5,
                         bottom: 10,
                         leading: 25)
            
            ZStack {
                
                Color("background1")
                
                ScrollView {
                    if selected2==0 {
                        ForEach(channelDC.CRs.filter({ $0.isSender==false }), id: \.channelID) { channelRequest in
                            
                            VStack(spacing: 0) {
                                ChannelRequestRow(channelRequest: channelRequest)
                                    .padding(.horizontal, SP.screenWidth*0.1)
                                    .padding(.vertical, SP.safeAreaHeight*0.0225)
                                
                                Divider()
                            }
                        }
                    } else if selected2==1 {
                        ForEach(channelDC.CRs.filter({ $0.isSender==true }), id: \.channelID) { channelRequest in
                            
                            VStack(spacing: 0) {
                                ChannelRequestRow(channelRequest: channelRequest)
                                    .padding(.horizontal, SP.screenWidth*0.1)
                                    .padding(.vertical, SP.safeAreaHeight*0.0225)
                                
                                Divider()
                            }
                        }
                    }
                }
            }
        }
    }
}

