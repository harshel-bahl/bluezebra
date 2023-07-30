//
//  DeletionLog.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 25/03/2023.
//

import SwiftUI

struct DeletionLog: View {
    
    @State var channelType: String
    
    @EnvironmentObject var SP: ScreenProperties
    
    @ObservedObject var channelDC = ChannelDC.shared
    
    init(channelType: String) {
        self._channelType = State(wrappedValue: channelType)
    }
    
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
                
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(spacing: 0) {
                        ForEach(self.filterCDs(channelType: channelType), id: \.deletionID) { CD in
                            DeletionRow(CD: CD)
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    func filterCDs(channelType: String) -> [SChannelDeletion] {
        let CDs = channelDC.CDs.filter({ $0.channelType == channelType })
        return CDs
    }
}


