//
//  AddUserRow.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 25/03/2023.
//

import SwiftUI

struct AddUserRow: View {
    
    @ObservedObject var channelDC = ChannelDC.shared
    
    let remoteUser: RemoteUserPacket
    
    @State var requestSent = false
    @State var sendChannelRequestFailure = false
    
    var body: some View {
        HStack {
            Text(remoteUser.username)
            
            Spacer()
            
            if requestSent == false {
                Button(action:{
                    channelDC.sendChannelRequest(RUPacket: remoteUser) { result in
                        switch result {
                        case .success(): self.requestSent = true
                        case .failure(_): self.sendChannelRequestFailure = true
                        }
                    }
                }) {
                    Image(systemName: "plus.message")
                        .resizable()
                        .padding(5)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .background(Color.secondary)
                        .clipShape(Circle())
                        .foregroundColor(.white)
                }
            } else {
                Image(systemName: "checkmark.message")
                    .resizable()
                    .padding(5)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 30, height: 30)
                    .background(Color.secondary)
                    .clipShape(Circle())
                    .foregroundColor(.white)
            }
        }
        .alert("Failed to send channel request", isPresented: $sendChannelRequestFailure) {
            Button("Try again later", role: .cancel) {
            }
        }
    }
}

