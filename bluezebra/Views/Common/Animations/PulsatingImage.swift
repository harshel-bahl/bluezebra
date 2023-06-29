//
//  PulsatingImage.swift
//  bluezebra
//
//  Created by Harshel Bahl on 27/06/2023.
//

import SwiftUI

struct PulsatingImage: View {
    
    /// PulsatingImage
    /// scaleRatio needs to be smaller than 1, so size represents maximum size
    /// animationSpeed = 0 prevents pulsating
    
    @State private var sizeChanged = false
    
    var size: CGSize
    var backgroundColour: Color
    var imageColour: Color
    var imageName: String
    var scaleRatio: CGFloat
    var animationSpeed: Double
    
    init(size: CGSize = CGSize(width: 50, height: 50),
         backgroundColour: Color = .white,
         imageColour: Color,
         imageName: String,
         scaleRatio: CGFloat,
         animationSpeed: Double = 0) {
        self.size = size
        self.backgroundColour = backgroundColour
        self.imageColour = imageColour
        self.imageName = imageName
        self.scaleRatio = scaleRatio
        self.animationSpeed = animationSpeed
    }
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(backgroundColour)
            
            Image(systemName: imageName)
                .font(.system(size: size.height * 0.9))
                .foregroundColor(imageColour)
        }
        .frame(width: size.width, height: size.height)
        .scaleEffect(sizeChanged ? scaleRatio : 1)
        .animation(Animation.easeInOut(duration: self.animationSpeed).repeatForever(),
                   value: self.sizeChanged)
        .onAppear {
            self.sizeChanged = true
        }
    }
}


