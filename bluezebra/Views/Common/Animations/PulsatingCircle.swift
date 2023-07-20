//
//  PulsatingCircle.swift
//  bluezebra
//
//  Created by Harshel Bahl on 27/06/2023.
//

import SwiftUI

struct PulsatingCircle: View {
    
    /// PulsatingCircle
    /// scaleRatio needs to be smaller than 1, so size represents maximum size
    /// animationSpeed = 0 prevents pulsating
    
    @State private var sizeChanged = false
    
    var size: CGSize
    var colour: Color
    var scaleRatio: CGFloat
    var animationSpeed: Double
    var text: String?
    var textColour: Color
    var fontSize: CGFloat
    var fontWeight: Font.Weight
    var padding: CGFloat
    
    init(size: CGSize = CGSize(width: 9, height: 9),
         colour: Color = .green,
         scaleRatio: CGFloat = 0.8,
         animationSpeed: Double = 1.5,
         text: String? = nil,
         textColour: Color = .black,
         fontSize: CGFloat = 10,
         fontWeight: Font.Weight = .regular,
         padding: CGFloat = 5) {
        self.size = size
        self.colour = colour
        self.scaleRatio = scaleRatio
        self.animationSpeed = animationSpeed
        self.text = text
        self.textColour = textColour
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.padding = padding
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Circle()
                .fill(colour)
                .frame(width: size.width, height: size.height)
                .scaleEffect(sizeChanged ? scaleRatio : 1)
                .animation(Animation.easeInOut(duration: self.animationSpeed).repeatForever(),
                           value: self.sizeChanged)
                .onAppear {
                    self.sizeChanged = true
                }
            
            if let text = self.text {
                Text(text)
                    .font(.system(size: self.fontSize))
                    .foregroundColor(self.textColour)
                    .fontWeight(self.fontWeight)
                    .padding(.leading, padding)
            }
        }
    }
}

