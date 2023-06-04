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
        Button(action: {
            userDC.deleteUser() { result in }
        }, label: {
            Text("Delete User")
        })
    }
}


