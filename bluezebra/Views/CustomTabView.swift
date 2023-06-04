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
        GeometryReader { geometry in
            ZStack {
                Color("background3")

                VStack(spacing: 0) {
                    
                    Color.clear
                        .frame(height: geometry.size.height*0.1)

                    HStack(spacing: 0) {

                        Spacer()

                        Button(action: {
                            tab = "teams"
                        }, label: {

                            VStack(spacing: 0) {
                                Image(systemName: tab=="teams" ? "person.2.circle.fill" : "person.2.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(tab=="teams" ? Color("blueAccent1") : Color("darkAccent1"))
                                    .frame(height: geometry.size.height*0.475)
                                
                                
                                Text("teams")
                                    .font(.system(size: geometry.size.height*0.225))
                                    .foregroundColor(tab=="teams" ? Color("blueAccent1") : Color("darkAccent1"))
                                    .padding(.top, geometry.size.height*0.15)
                                    .frame(height: geometry.size.height*0.375)
                            }
                            .frame(height: geometry.size.height*0.85)
                            .padding(.bottom, geometry.size.height*0.05)
                        })
                        .padding(.trailing, geometry.size.width*0.15)

                        
                        Button(action: {
                            tab = "channels"
                        }, label: {

                            VStack(spacing: 0) {
                                Image(systemName: tab=="channels" ? "message.circle.fill" : "message.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(tab=="channels" ? Color("blueAccent1") : Color("darkAccent1"))
                                    .frame(height: geometry.size.height*0.475)
                                
                                
                                Text("channels")
                                    .font(.system(size: geometry.size.height*0.225))
                                    .foregroundColor(tab=="channels" ? Color("blueAccent1") : Color("darkAccent1"))
                                    .padding(.top, geometry.size.height*0.15)
                                    .frame(height: geometry.size.height*0.375)
                            }
                            .frame(height: geometry.size.height*0.85)
                            .padding(.bottom, geometry.size.height*0.05)
                        })
                        
                        
                        Button(action: {
                            tab = "profile"
                        }, label: {

                            VStack(spacing: 0) {
                                Image(systemName: tab=="profile" ? "person.crop.circle.fill" : "person.crop.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(tab=="profile" ? Color("blueAccent1") : Color("darkAccent1"))
                                    .frame(height: geometry.size.height*0.475)
                                
                                
                                Text("profile")
                                    .font(.system(size: geometry.size.height*0.225))
                                    .foregroundColor(tab=="profile" ? Color("blueAccent1") : Color("darkAccent1"))
                                    .padding(.top, geometry.size.height*0.15)
                                    .frame(height: geometry.size.height*0.375)
                            }
                            .frame(height: geometry.size.height*0.85)
                            .padding(.bottom, geometry.size.height*0.05)
                        })
                        .padding(.leading, geometry.size.width*0.15)

                        Spacer()
                    }
                    .frame(height: geometry.size.height*0.9)
                }
                
                VStack(spacing: 0) {
                    Divider()
                    
                    Spacer()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

