//
//  UserRequestsView.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 04/04/2023.
//

import SwiftUI

struct UserRequestsView: View {
    
    @Binding var showUserRequestsView: Bool
    
    @State var segment = 0
    
    var body: some View {
        ZStack {
            
//            Color.black
            
            VStack {
                Picker("", selection: $segment) {
                    Text("Add Users").tag(0)
                    Text("Requests").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(10)
                
                if segment==0 {
                    AddUser()
                } else {
                    ChannelRequests()
                }
            }
        }
    }
}

