//
//  NavBar.swift
//  bluezebra
//
//  Created by Harshel Bahl on 15/07/2023.
//

import SwiftUI

struct NavBar<Content1: View, Content2: View>: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var SP: ScreenProperties
    
    let backIconSize: CGSize
    let backIconColour: Color
    
    let BG: Color
    
    let contentPadding: EdgeInsets
    
    let content1: () -> Content1
    
    let showContent2: Bool
    let content2: () -> Content2
    
    init(backIconSize: CGSize = .init(width: 15, height: 20),
         backIconColour: Color = Color("accent1"),
         BG: Color = Color("background5").opacity(0.85),
         contentPadding: EdgeInsets = .init(top: 5, leading: 80, bottom: 5, trailing: 50),
         @ViewBuilder content1: @escaping () -> Content1,
         showContent2: Bool = false,
         @ViewBuilder content2: @escaping () -> Content2 = { Color.clear }) {
        self.backIconSize = backIconSize
        self.backIconColour = backIconColour
        self.BG = BG
        self.contentPadding = contentPadding
        self.content1 = content1
        self.showContent2 = showContent2
        self.content2 = content2
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            Color.clear
                .frame(height: SP.topSAI)
            
            ZStack {
                HStack(spacing: 0) {
                    if showContent2 {
                        content2()
                    } else {
                        SystemIcon(systemName: "chevron.left",
                                   size: backIconSize,
                                   colour: backIconColour,
                                   buttonAction: {
                            self.presentationMode.wrappedValue.dismiss()
                        })
                    }

                    Spacer()
                }
                .edgePadding(leading: 12.5)

                HStack(spacing: 0) {
                    content1()
                }
                .padding(contentPadding)
            }
        }
        .background { BG }
        .navigationBarBackButtonHidden(true)
        .ignoresSafeArea()
    }
}

