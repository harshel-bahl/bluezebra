//
//  AddUserRow.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 25/03/2023.
//

import SwiftUI

struct AddRURow: View {
    
    @EnvironmentObject var SP: ScreenProperties
    
    @ObservedObject var channelDC = ChannelDC.shared
    
    let RU: RUPacket
    
    @State var requestSent = false
    @State var requestFailure = false
    
    var body: some View {
        HStack(spacing: 0) {
            
            EmojiIcon(avatar: RU.avatar,
                      size: .init(width: 40, height: 40),
                      emojis: BZEmojiProvider1.shared.getAll(),
                      buttonAction: { avatar in
                
            })
            .edgePadding(trailing: 15)
            
            FixedText(text: "@" + RU.username,
                      colour: Color("accent1"),
                      fontSize: 18,
                      fontWeight: .medium)
            
            Spacer()
            
            if checkRequests(userID: RU.userID) {
                SystemIcon(systemName: "checkmark.circle.fill",
                           size: .init(width: 25, height: 25),
                           colour: Color("accent1"))
            } else {
                requestFlow
            }
        }
        .alert("Failed to send channel request", isPresented: $requestFailure) {
            Button("Try again later", role: .cancel) {
            }
        }
    }
    
    @ViewBuilder
    var requestFlow: some View {
        if requestSent == false {
            SystemIcon(systemName: "plus.circle.fill",
                       size: .init(width: 25, height: 25),
                       colour: Color("accent1"),
                       buttonAction: {
                channelDC.sendCR(remoteUser: RU) { result in
                    switch result {
                    case .success():
                        withAnimation() {
                            self.requestSent = true
                        }
                    case .failure(_):
                        withAnimation {
                            self.requestFailure = true
                        }
                    }
                }
            })
        } else {
            SystemIcon(systemName: "checkmark.circle.fill",
                       size: .init(width: 25, height: 25),
                       colour: Color("accent1"))
            
        }
    }
    
    func checkRequests(userID: String) -> Bool {
        if let _ = channelDC.CRs.first(where: { $0.userID == userID }) {
            return true
        } else {
            return false
        }
    }
}

