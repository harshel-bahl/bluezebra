//
//  TeamsList.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 01/04/2023.
//

import SwiftUI

struct TeamsList: View {
    
    @ObservedObject var userDC = UserDC.shared
    @ObservedObject var channelDC = ChannelDC.shared
    @ObservedObject var messageDC = MessageDC.shared
    
    @EnvironmentObject var SP: ScreenProperties
    
    @State var showTeamRequestsView = false
    @State var showDeletionLog = false
    
    var body: some View {
        ZStack {
            Color("background2")
            
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    
                    Button(action: { showDeletionLog.toggle() }, label: {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(minWidth: 15, maxWidth: SP.width*0.06)
                            .foregroundColor(Color("blueAccent1"))
                    })
                    
                    Spacer()
                    
                    Text("Teams")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(Color("text1"))
                    
                    Spacer()
                    
                    Button(action: { showTeamRequestsView.toggle() }, label: {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(minWidth: 15, maxWidth: SP.width*0.06)
                            .foregroundColor(Color("blueAccent1"))
                    })
                }
                .padding(.leading, SP.width*0.05)
                .padding(.trailing, SP.width*0.05)
                .padding(.top, SP.safeAreaHeight*0.02)
                .padding(.bottom, SP.safeAreaHeight*0.01)
                
                Divider()
                
                List {
                    ForEach(channelDC.userChannels, id: \.channelID) { channel in
                        
                        ChannelView(channel: channel)
                            .listRowBackground(Color.black)
                    }
                }
                .listStyle(.plain)
            }
            .sheet(isPresented: $showTeamRequestsView, content: {
                UserRequestsView(showUserRequestsView: $showTeamRequestsView)
            })
            .sheet(isPresented: $showDeletionLog, content: {
                DeletionLog()
            })
        }
    }
}


