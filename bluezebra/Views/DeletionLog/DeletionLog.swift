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
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                FixedText(text: "Deletion Log",
                          colour: Color("text1"),
                          fontSize: 20,
                          fontWeight: .bold)
                
                Spacer()
            }
            .edgePadding(top: 7.5, bottom: 10, leading: 25)
            .background(Color("background3"))
            
            Divider()
            
            ZStack {
                
                Color("background1")
                
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filterCDs(channelType: channelType), id: \.deletionID) { CD in
                            DeletionRow(CD: CD)
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    func filterCDs(channelType: String) -> [SChannelDeletion] {
        return channelDC.CDs.filter({ $0.channelType == channelType })
    }
}


