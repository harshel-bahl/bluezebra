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
    
    var body: some View {
        VStack {
            
            HStack(spacing: 0) {
                if let created = userDC.userData?.creationDate {
                    (Text("Created: ")
                        .fontWeight(.regular) +
                     Text(DateU.shared.dateDMY(date: created))
                        .fontWeight(.bold)
                    )
                    .font(.subheadline)
                    .foregroundColor(Color("text2"))
                }
                
                Spacer()
            }
            
//            ButtonTemp(label: "Reset Accout",
//                       backgroundColour: Color.orange,
//                       foregroundColour: Color("text1")) {
//                Task {
//                    try? await userDC.resetUserData()
//                }
//            }
//
            ButtonAni(label: "Delete Account",
                      fontSize: 18,
                      foregroundColour: Color.white,
                      BGColour: Color.red,
                      action: {
                Task {
                    try? await userDC.hardReset()
                }
            })
        }
    }
}


