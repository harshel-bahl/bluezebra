//
//  DeletionLog.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 25/03/2023.
//

import SwiftUI

struct DeletionLog: View {
    
    @EnvironmentObject var SP: ScreenProperties

    @ObservedObject var channelDC = ChannelDC.shared
    
    var body: some View {
        ZStack {
            Color("background3")
            
            VStack(spacing: 0) {
                
                Rectangle()
                    .fill(Color("darkAccent1").opacity(0.75))
                    .frame(width: SP.width*0.08, height: 5)
                    .cornerRadius(7.5)
                    .padding(.vertical, SP.safeAreaHeight*0.01)
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        Text("Deletion Log")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(Color("text1"))
                        
                        Spacer()
                    }
                    .padding(.bottom, SP.safeAreaHeight*0.01)
                    .padding(.horizontal, SP.width*0.033)
                    
                    Divider()
                }
                .padding(.top, SP.safeAreaHeight*0.025)
                
                
                ZStack {
                    
                    Color("background1")
                    
                    ScrollView {
                        ForEach(channelDC.channelDeletions, id: \.deletionID) { deletion in
                            deletionRow(deletion: deletion)
                        }
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    
    func deletionRow(deletion: SChannelDeletion) -> some View {
        HStack(spacing: 0) {
            
        }
    }
}


