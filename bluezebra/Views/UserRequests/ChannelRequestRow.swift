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
    
    init(channelRequest: SChannelRequest) {
        self.channelRequest = channelRequest

    }
    
    var body: some View {
        
        if let remoteUser = remoteUser {
            HStack {
                
                Text(remoteUser.username)
                
                Spacer()
                
                channelRequestButton(result: true, sfSymbol: "person")
                
                channelRequestButton(result: false, sfSymbol: "square.and.pencil")
            }
        }
    }
    
    func fetchRemoteUser() {
        Task {
            guard let remoteUserID = channelRequest.userID else { return }
            
            if let remoteUser = try? await channelDC.fetchRemoteUserLocally(userID: remoteUserID) {
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
            channelDC.sendUserCRResult(channelRequest: self.channelRequest, result: result) { result in
                
            }
        }, label: {
            Image(systemName: sfSymbol)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 15, height: 15)
                .foregroundColor(.black)
                .padding()
        })
        
        return button
    }
}


