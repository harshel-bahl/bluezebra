//
//  UserRequestsView.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 04/04/2023.
//

import SwiftUI

struct CRView: View {
    
    @EnvironmentObject var SP: ScreenProperties
    
    @ObservedObject var userDC = UserDC.shared
    @ObservedObject var channelDC = ChannelDC.shared
    
    @Binding var showCRView: Bool
    
    @State var selected1: Int = 0
    @State var selected2: Int = 0
    
    @State var username = ""
    @FocusState var focusField: String?
    @State var fetchedUsers = [RUPacket]()
    @State var searchFailure = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            SimpleTextSegment(selected: $selected1,
                              textNames: ["Add Users", "Requests"],
                              fontSize: 16,
                              width: 200,
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
                    LazyVStack(spacing: 0){
                        ForEach(filteredFUs(fetchedUsers: fetchedUsers), id: \.userID) { user in
                            AddRURow(RU: user)
                                .edgePadding(top: 12.5,
                                             bottom: 12.5,
                                             leading: 30,
                                             trailing: 35)
                            
                            Divider()
                        }
                    }
                }
            }
        }
        .keyboardAwarePadding()
    }
    
    func filteredFUs(fetchedUsers: [RUPacket]) -> [RUPacket] {
        let filteredFUs = fetchedUsers.filter({ RU in
            if channelDC.CRs.contains(where: { $0.userID == RU.userID && !$0.isSender}) {
                return false
            } else if userDC.userData!.userID == RU.userID {
                return false
            } else {
                return true
            }
        })
       
        return filteredFUs
    }
    
    func usernameTextField() -> some View {
        DebounceTextField(text: $username,
                          startingText: "@",
                          foregroundColour: Color("text3"),
                          font: .system(size: 18),
                          characterLimit: 13,
                          valuesToRemove: BZSetup.shared.removeUsernameValues,
                          autocorrection: false,
                          trimOnCommit: true,
                          replaceStartingOnCommit: true,
                          debouncedAction: { username in
            
            Task {
                do {
                    let RUPackets = try await channelDC.fetchRUs(username: username,
                                                                 checkUsername: false)
                    self.fetchedUsers = RUPackets
                } catch {
                    
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
            
            HStack(spacing: 0) {
                SimpleTextSegment(selected: $selected2,
                                  textNames: ["received", "sent"],
                                  fontSize: 12,
                                  width: 130,
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
                    LazyVStack(spacing: 0) {
                        if selected2==0 {
                            ForEach(channelDC.CRs.filter({ $0.isSender==false }), id: \.requestID) { CR in
                                if let RU = channelDC.RUs[CR.userID] {
                                    VStack(spacing: 0) {
                                        CRRow(CR: CR,
                                              RU: RU)
                                        .edgePadding(top: 12.5,
                                                     bottom: 12.5,
                                                     leading: 30,
                                                     trailing: 35)
                                        
                                        Divider()
                                    }
                                }
                            }
                        } else if selected2==1 {
                            ForEach(channelDC.CRs.filter({ $0.isSender==true }), id: \.requestID) { CR in
                                if let RU = channelDC.RUs[CR.userID] {
                                    VStack(spacing: 0) {
                                        CRRow(CR: CR,
                                              RU: RU)
                                        .edgePadding(top: 12.5,
                                                     bottom: 12.5,
                                                     leading: 30,
                                                     trailing: 35)
                                        
                                        Divider()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

