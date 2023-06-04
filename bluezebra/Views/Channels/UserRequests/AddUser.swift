//
//  AddUser.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 24/01/2023.
//

import SwiftUI

struct AddUser: View {
    
    @ObservedObject var userDC = UserDC.shared
    @ObservedObject var channelDC = ChannelDC.shared
    
    @ObservedObject var usernameTextManager = TextBindingManager(limit: 13)
    
    @State var fetchedUsers = [RemoteUserPacket]()
    
    @State var searchFailure = false
    
    @FocusState var usernameField: Bool
    
    var body: some View {
        VStack {
            
            HStack {
                
                usernameTextfield
                    .onAppear { usernameField.toggle() }
                
                if self.usernameTextManager.username != "" {
                    Button(action:{
                        channelDC.fetchRemoteUser(userID: nil, username: usernameTextManager.username) { (userDataList) in
                            switch userDataList {
                            case .success(let users): fetchedUsers = users
                            case .failure(_): searchFailure = true
                            }
                        }
                    }) {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .padding(5)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .background(Color.secondary)
                            .clipShape(Circle())
                            .foregroundColor(.white)
                    }
                }
            }
            
            List {
                ForEach(fetchedUsers, id: \.userID) { user in
                    AddUserRow(remoteUser: user)
                }
            }
            
            Spacer()
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
    
    var usernameTextfield: some View {
        let textfield = TextField("Username",
                                  text: $usernameTextManager.username,
                                  onEditingChanged: { isEditing in
            if isEditing {
            }
        },
                                  onCommit: {
            let username = usernameTextManager.username.replacingOccurrences(of: "@", with: "")
            
            userDC.checkUsername(username: username) { result in
                switch result {
                case .success(let result): break
                    //                                        withAnimation(.easeInOut(duration: 0.3)) {
                    //                                            self.checkedUsername = result
                    //                                        }
                case .failure(_): break
                }
            }
        })
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .foregroundColor(Color("text3"))
            .scrollContentBackground(.hidden)
            .font(.headline)
            .fontWeight(.regular)
            .focused($usernameField)
            .submitLabel(.go)
            .onChange(of: usernameTextManager.username) { username in
                if username.isEmpty {
                    usernameTextManager.username = username + "@"
                } else if username.first != "@" {
                    usernameTextManager.username.insert("@", at: usernameTextManager.username.startIndex)
                }
            }
        
        return textfield
    }
    
//    var searchUserButton: some View {
//        Button(action: {
//            if channel.channelType == "personal" {
//                Task() {
//                    if !message.isEmpty {
//                        let sMessage = try? await messageDC.createMessage(message: message,
//                                                                          type: "text")
//                        if let sMessage = sMessage { messageDC.personalMessages.insert(sMessage, at: 0) }
//                        
//                        self.message.removeAll()
//                    }
//                }
//            }
//        }, label: {
//            Image(systemName: message.isEmpty ? "arrow.up.circle" : "arrow.up.circle.fill")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .foregroundColor(Color("blueAccent1"))
//                .frame(width: (initialTFSize?.height ?? SP.width*0.1) - SP.safeAreaHeight*0.025,
//                       height: (initialTFSize?.height ?? SP.width*0.1) - SP.safeAreaHeight*0.025)
//        })
//        .disabled(message.isEmpty)
//    }
}


