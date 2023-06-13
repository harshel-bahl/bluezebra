//
//  AddUserRow.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 25/03/2023.
//

import SwiftUI

struct AddUserRow: View {
    
    @EnvironmentObject var SP: ScreenProperties
    
    @ObservedObject var channelDC = ChannelDC.shared
    
    let remoteUser: RemoteUserPacket
    
    @State var requestSent = false
    @State var requestFailure = false
    
    var body: some View {
        HStack(spacing: 0) {
            
            Avatar(avatar: remoteUser.avatar, size: .init(width: 40,
                                                          height: 40))
            .padding(.trailing, 20)
            
            Text("@" + remoteUser.username)
                .font(.headline)
                .foregroundColor(Color("blueAccent1"))
            
            Spacer()
            
            if requestSent == false {
                requestButton
            } else {
                sentLabel
            }
        }
        .alert("Failed to send channel request", isPresented: $requestFailure) {
            Button("Try again later", role: .cancel) {
            }
        }
    }
    
    var requestButton: some View {
        Button(action:{
            channelDC.sendChannelRequest(RUPacket: remoteUser) { result in
                switch result {
                case .success():
                    self.requestSent = true
                case .failure(_):
                    self.requestFailure = true
                }
            }
        }) {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 25, height: 25)
                .foregroundColor(Color("blueAccent1"))
        }
    }
    
    var sentLabel: some View {
        Image(systemName: "checkmark.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25)
            .foregroundColor(Color("blueAccent1"))
    }
}

