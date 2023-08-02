//
//  ChannelRequestRow.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 25/03/2023.
//

import SwiftUI

struct CRRow: View {
    
    @ObservedObject var channelDC = ChannelDC.shared
    
    let CR: SChannelRequest
    let RU: SRemoteUser
    
    @State var requestFailure = false
    
    init(CR: SChannelRequest,
         RU: SRemoteUser) {
        self.CR = CR
        self.RU = RU
    }
    
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
            
            if !CR.isSender {
                CRButtons(result: false,
                          sfSymbol: "xmark.circle")
                .edgePadding(trailing: 15)
                
                CRButtons(result: true,
                          sfSymbol: "checkmark.circle")
            } else {
                DateTimeMed(date: CR.date,
                            fontSize: 15,
                            colour: Color("text2"))
            }
        }
        .alert("Failed to send channel request", isPresented: $requestFailure) {
            Button("Try again later", role: .cancel) {
            }
        }
    }
    
    func CRButtons(result: Bool, sfSymbol: String) -> some View {
        SystemIcon(systemName: sfSymbol,
                   size: .init(width: 25, height: 25),
                   colour: Color("accent1"),
        buttonAction: {
//            channelDC.sendCRResult(CR: self.CR,
//                                   result: result) { result in
//                
//            }
        })
    }
}


