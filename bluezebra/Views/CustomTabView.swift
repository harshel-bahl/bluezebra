//
//  CustomTabView.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 09/01/2023.
//

import SwiftUI

struct CustomTabView: View {
    
    @EnvironmentObject var SP: ScreenProperties
    
    @Binding var tab: String
    
    var body: some View {
        HStack(spacing: 0) {
            
            Spacer()
            
            Button(action: {
                tab = "channels"
            }, label: {
                VStack(spacing: 0) {
                    Image(systemName: tab=="channels" ? "message.circle.fill" : "message.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(tab=="channels" ? Color("blueAccent1") : Color("darkAccent1"))
                        .frame(width: 27.5, height: 27.5)
                    
                    Text("channels")
                        .font(.caption)
                        .foregroundColor(tab=="channels" ? Color("blueAccent1") : Color("darkAccent1"))
                        .padding(.top, 7.5)
                }
            })
            .padding(.trailing, SP.screenWidth*0.1)
            
            Button(action: {
                tab = "profile"
            }, label: {
                VStack(spacing: 0) {
                    Image(systemName: tab=="profile" ? "person.crop.circle.fill" : "person.crop.circle")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(tab=="profile" ? Color("blueAccent1") : Color("darkAccent1"))
                        .frame(width: 27.5, height: 27.5)
                    
                    Text("profile")
                        .font(.caption)
                        .foregroundColor(tab=="profile" ? Color("blueAccent1") : Color("darkAccent1"))
                        .padding(.top, 7.5)
                }
            })
            .padding(.leading, SP.screenWidth*0.1)
            
            Spacer()
        }
        .padding(.top, 5)
        .padding(.bottom, 5)
        .background(Color("background3"))
    }
}


