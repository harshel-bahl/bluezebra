//
//  ChannelsList.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 07/01/2023.
//

import SwiftUI

struct ChannelsList: View {
    
    @ObservedObject var userDC = UserDC.shared
    @ObservedObject var channelDC = ChannelDC.shared
    @ObservedObject var messageDC = MessageDC.shared
    
    @EnvironmentObject var SP: ScreenProperties
    
    @State var showCRView = false
    @State var showDeletionLog = false
    
    @State var chatNavigation: String? = nil
    
    @State var textSize: CGSize = .zero
    
    var body: some View {
        VStack(spacing: 0) {
            
            banner
                .edgePadding(top: 10,
                             bottom: 10,
                             leading: 20,
                             trailing: 20)
            
            Divider()
            
            ScrollView() {
                LazyVStack(spacing: 0) {
                    ForEach(channelList(), id: \.channelID) { channel in
                        
                        if channel.channelType == "personal" {
                            ChannelView(channel: channel)
                        } else if let RU = channelDC.RUs[channel.uID] {
                            ChannelView(channel: channel,
                                        RU: RU)
                        }
                    }
                }
            }
            
        }
        .sheetModifier(isPresented: $showCRView,
                       BG: Color("background3")) {
            CRView(showCRView: $showCRView)
        }
                       .sheetModifier(isPresented: $showDeletionLog,
                                      BG: Color("background3")) {
                           DeletionLog(channelType: "RU")
                       }
    }
    
    
    var banner: some View {
        HStack(alignment: .center, spacing: 0) {
            
            SystemIcon(systemName: "arrow.uturn.backward.circle",
                       size: .init(width: 25, height: 25),
                       colour: Color("accent1"),
                       BGColour: Color("accent4"),
                       applyClip: true,
                       shadow: 1.2,
            buttonAction: {
                showDeletionLog.toggle()
            })
            
            Spacer()
            
            FixedText(text: "Channels",
                      colour: Color("text1"),
                      fontSize: 16,
                      fontWeight: .bold)
            
            Spacer()
            
            SystemIcon(systemName: "plus.circle",
                       size: .init(width: 25, height: 25),
                       colour: Color("accent1"),
                       BGColour: Color("accent4"),
                       applyClip: true,
                       shadow: 1.2,
            buttonAction: {
                showCRView.toggle()
            })
        }
        .frame(height: 25)
    }
    
    func channelList() -> [SChannel] {
        var channelList = channelDC.RUChannels
        
        if let personalChannel = channelDC.personalChannel {
            channelList.insert(personalChannel, at: 0)
        }
        
        return channelList
    }
}


