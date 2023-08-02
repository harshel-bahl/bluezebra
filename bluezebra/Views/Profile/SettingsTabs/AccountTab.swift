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
            
            
            ButtonAni(label: "Reset Account",
                      fontSize: 18,
                      foregroundColour: Color.white,
                      BGColour: Color.red,
                      action: {
                Task {
                    do {
                        try await userDC.resetUserData()
                    } catch {
                        resetFailure = true
                    }
                }
            })

            ButtonAni(label: "Delete Account",
                      fontSize: 18,
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
        }
    }
}


