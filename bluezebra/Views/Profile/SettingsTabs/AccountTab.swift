//
//  AccountTab.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 13/02/2023.
//

import SwiftUI

struct AccountTab: View {
    
    @ObservedObject var userDC = UserDC.shared
    @ObservedObject var channelDC = ChannelDC.shared
    
    @State var resetFailure = false
    @State var deletionFailure = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            NavBar(contentPadding: EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0),
                   content1: {
                HStack(alignment: .center, spacing: 0) {
                    
                    Spacer()
                    
                    FixedText(text: "Account",
                              colour: Color("text1"),
                              fontSize: 16,
                              fontWeight: .bold)
                    
                    Spacer()
                }
                .frame(height: 25)
            })
            
            Form {
                Section("Userdata") {
                    
                    FixedText(text: "Username: " + userDC.userData!.username,
                              colour: Color("text2"),
                              fontSize: 16)
                    
                    HStack(spacing: 0) {
                        FixedText(text: "Creation Date: ",
                                  colour: Color("text2"),
                                  fontSize: 16)
                        
                        DateTimeLong(date: userDC.userData!.creationDate,
                                     fontSize: 16,
                                     colour: Color("text2"))
                    }
                    
                    HStack(spacing: 0) {
                        FixedText(text: "Last Online: ",
                                  colour: Color("text2"),
                                  fontSize: 16)
                        
                        if let lastOnline = userDC.userData!.lastOnline {
                            DateTimeLong(date: lastOnline,
                                         fontSize: 16,
                                         colour: Color("text2"))
                        } else {
                            FixedText(text: "-",
                                      colour: Color("text2"),
                                      fontSize: 16)
                        }
                    }
                }
                
                Section("Reset Channels") {
                    
                    FixedText(text: "This action will reset delete all your channel messages. Notifications will be sent to all users you've interacted with to reset your channels.",
                              colour: Color("text2"),
                              fontSize: 15)
                    
                    HStack {
                        Spacer()
                        
                        ButtonAni(label: "Reset Channels",
                                  fontSize: 16,
                                  foregroundColour: Color.white,
                                  BGColour: Color("accent6"),
                                  action: {
                            Task {
                                do {
                                    try await userDC.resetUserData()
                                } catch {
                                    resetFailure = true
                                }
                            }
                        })
                        
                        Spacer()
                    }
                }
                
                Section("Delete Account") {
                    
                    FixedText(text: "This action deletes all device data, server data and sends notifications to all users you've interacted with to delete your userdata",
                              colour: Color("text2"),
                              fontSize: 15)
                    
                    HStack {
                        Spacer()
                        
                        ButtonAni(label: "Delete Account",
                                  fontSize: 16,
                                  foregroundColour: Color.white,
                                  BGColour: Color.red,
                                  action: {
                            Task {
                                do {
                                    try await userDC.deleteUser()
                                } catch {
                                    deletionFailure = true
                                }
                            }
                        })
                        
                        Spacer()
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
}


