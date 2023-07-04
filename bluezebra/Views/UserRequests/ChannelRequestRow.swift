//
//  ChannelRequestRow.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 25/03/2023.
//

import SwiftUI

struct ChannelRequestRow: View {
    
    @ObservedObject var channelDC = ChannelDC.shared
    
    var channelRequest: SChannelRequest
    
    @State var remoteUser: SRemoteUser?
    
    @State var requestFailure = false
    
    init(channelRequest: SChannelRequest) {
        self.channelRequest = channelRequest
    }
    
    var body: some View {
        HStack(spacing: 0) {
            
            if let remoteUser = remoteUser {
                
                HStack(spacing: 0) {
                    
//                    Avatar(avatar: remoteUser.avatar, size: .init(width: 40,
//                                                                  height: 40))
//                    .padding(.trailing, 20)
                    
                    Text("@" + remoteUser.username)
                        .font(.headline)
                        .foregroundColor(Color("blueAccent1"))
                    
                    Spacer()
                    
                    if !channelRequest.isSender {
                        channelRequestButton(result: false, sfSymbol: "xmark.circle")
                            .padding(.trailing, 22.5)
                        
                        channelRequestButton(result: true, sfSymbol: "checkmark.circle")
                    } else {
//                        DateTimeLabel(date: channelRequest.date,
//                                      font: .subheadline,
//                                      colour: Color("text1"),
//                                      mode: 2)
                    }
                }
            }
        }
        .onAppear() { fetchRemoteUser() }
        .alert("Failed to send channel request", isPresented: $requestFailure) {
            Button("Try again later", role: .cancel) {
            }
        }
    }
    
    func fetchRemoteUser() {
        Task {
            guard let remoteUserID = channelRequest.userID else { return }
            
            if let remoteUser = try? await channelDC.fetchRULocally(userID: remoteUserID) {
                self.remoteUser = remoteUser
            } else {
                //                channelDC.fetchRemoteUser(userID: remoteUserID, username: nil) { result in
                //                    switch result {
                //                    case .success(let remoteUser)
                //                    }
                //                }
            }
        }
    }
    
    func channelRequestButton(result: Bool, sfSymbol: String) -> some View {
        let button = Button(action: {
            channelDC.sendCRResult(channelRequest: self.channelRequest, result: result) { result in
                
            }
        }, label: {
            Image(systemName: sfSymbol)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 27.5, height: 27.5)
                .foregroundColor(Color("blueAccent1"))
        })
        
        return button
    }
}


