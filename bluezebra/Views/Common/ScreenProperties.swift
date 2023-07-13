//
//  ScreenProperties.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 07/02/2023.
//

import SwiftUI


struct SPView<Content: View>: View {
    
    var backgroundColour: Color
    
    @ViewBuilder var content: () -> Content
    
    @StateObject var SP = ScreenProperties()
    
    init(backgroundColour: Color,
         content: @escaping () -> Content) {
        self.backgroundColour = backgroundColour
        self.content = content
    }
    
    var body: some View {
        ZStack {
            
            backgroundColour
                .ignoresSafeArea()
            
            GeometryReader { proxy in
                Color.clear
                    .onAppear() {
                        self.SP.safeAreaHeight = UIScreen.main.bounds.height - proxy.safeAreaInsets.top - proxy.safeAreaInsets.bottom
                        self.SP.topSAI = proxy.safeAreaInsets.top
                        self.SP.bottomSAI = proxy.safeAreaInsets.bottom
                    }
            }
            
            content()
                .ignoresSafeArea()
                .environmentObject(SP)
        }
    }
}


class ScreenProperties: ObservableObject {
    @Published var screenHeight: CGFloat
    @Published var screenWidth: CGFloat
    @Published var safeAreaHeight: CGFloat
    @Published var topSAI: CGFloat
    @Published var bottomSAI: CGFloat
    
    init(screenHeight: CGFloat = UIScreen.main.bounds.height,
         screenWidth: CGFloat = UIScreen.main.bounds.width,
         safeAreaHeight: CGFloat = 0,
         topSAI: CGFloat = 0,
         bottomSAI: CGFloat = 0) {
        self.screenHeight = screenHeight
        self.screenWidth = screenWidth
        self.safeAreaHeight = safeAreaHeight
        self.topSAI = topSAI
        self.bottomSAI = bottomSAI
    }
}



