//
//  DeletionLog.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 25/03/2023.
//

import SwiftUI

struct DeletionLog: View {
    
    var channelType: String
    
    @EnvironmentObject var SP: ScreenProperties

    @ObservedObject var channelDC = ChannelDC.shared
    
    var body: some View {
        ZStack {
            Color("background3")
            
            VStack(spacing: 0) {
                
                Rectangle()
                    .fill(Color("darkAccent1").opacity(0.75))
                    .frame(width: 30, height: 5)
                    .cornerRadius(7.5)
                    .padding(.vertical, 12.5)
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text("Deletion Log")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color("text1"))
                        
                        Spacer()
                    }
                    .padding(.bottom, 10)
                    .padding(.horizontal, 17.5)
                    
                    Divider()
                }
                .padding(.top, 5)
                
                
                ZStack {
                    
                    Color("background1")
                    
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(filterCDs(channelType: channelType), id: \.deletionID) { CD in
                                deletionRow(CD: CD)
                            }
                        }
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    func filterCDs(channelType: String) -> [SChannelDeletion] {
        return channelDC.CDs.filter({ $0.channelType == channelType })
    }
    
    func deletionRow(CD: SChannelDeletion) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                
//                Avatar(avatar: CD.icon, size: .init(width: 40,
//                                                    height: 40))
//                .padding(.trailing, 20)
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        
                        Text("@" + CD.name)
                            .font(.headline)
                            .foregroundColor(Color("blueAccent1"))
                        
                        Spacer()
                        
                        DateTimeLabel(date: CD.deletionDate,
                                      font: .subheadline,
                                      colour: Color("text2"),
                                      mode: 2)
                    }
                    .padding(.bottom, 5)
                    
                    HStack(spacing: 0) {
                        if CD.type == "clear" {
                            Text("Type: Clean Channel")
                                .font(.system(size: 12.5))
                                .foregroundColor(Color("text2"))
                        } else if CD.type == "delete" {
                            Text("Type: Channel Deletion")
                                .font(.system(size: 12.5))
                                .foregroundColor(Color("text2"))
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 2.5)
                    
                    HStack(spacing: 0) {
                        if CD.isOrigin {
                            Text("Origin: Me")
                                .font(.system(size: 12.5))
                                .foregroundColor(Color("text2"))
                        } else {
                            Text("Origin: " + CD.name)
                                .font(.system(size: 12.5))
                                .foregroundColor(Color("text2"))
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 2.5)
                    
                    HStack(spacing: 0) {
                        if CD.toDeleteUserIDs.components(separatedBy: ",").isEmpty {
                            Text("Status: ")
                                .font(.system(size: 12.5))
                                .foregroundColor(Color("text2")) +
                            
                            Text("Completed")
                                .font(.system(size: 12.5))
                                .foregroundColor(Color.green)
                        } else {
                            Text("Status: ")
                                .font(.system(size: 12.5))
                                .foregroundColor(Color("text2")) +
                            
                            Text("Incomplete")
                                .font(.system(size: 12.5))
                                .foregroundColor(Color("orangeAccent1"))
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 12.5)
            .padding(.horizontal, 20)
           
            HStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    Divider()
                        .frame(width: SP.screenWidth - 7.5 - 15 - 2.5 - 45 - 12.5)
                }
            }
        }
    }
}


