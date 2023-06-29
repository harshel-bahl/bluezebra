//
//  TypingAni.swift
//  bluezebra
//
//  Created by Harshel Bahl on 28/06/2023.
//

import SwiftUI

struct TypingAni: View {
    
    let imageColour: Color
    let circleColour: Color
    let size: CGSize
    
    @Binding var isTyping: Bool
    
    private let bubbleAnimation: Animation = .spring(response: 1.5,
                                                     dampingFraction: 0.8,
                                                     blendDuration: 0).repeatForever(autoreverses: true)
    
    var body: some View {
        if isTyping {
            ZStack {
                Image(systemName: "bubble.left.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(imageColour.opacity(0.3))
                
                HStack(spacing: size.width*0.075) {
                    TypingCircle(circleColour: circleColour,
                                 delay: 0.0)
                    
                    TypingCircle(circleColour: circleColour,
                                 delay: 0.25)
                    
                    TypingCircle(circleColour: circleColour,
                                 delay: 0.5)
                }
                .offset(y: -size.height*0.05)
                .padding(.horizontal, size.width*0.1)
            }
            .frame(width: size.width,
                   height: size.height)
            .animation(bubbleAnimation, value: isTyping)
        }
    }
}

struct TypingCircle: View {
    
    @State private var typing = true
    
    let circleColour: Color
    var delay: CGFloat
    
    var body: some View {
        Circle()
            .fill(circleColour)
            .opacity(typing ? 0.25 : 0.75)
            .animation(.default.delay(delay), value: typing)
            .onAppear { animate() }
    }
    
    func animate() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            typing.toggle()
        }
    }
}


