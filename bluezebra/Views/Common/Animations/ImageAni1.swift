//
//  ImageAni1.swift
//  bluezebra
//
//  Created by Harshel Bahl on 17/05/2023.
//

import SwiftUI

struct ImageAni1: View {
    
    /// ImageAni1
    /// scaleRatio 1 for no size change
    /// backgroundBlur 0 for no background blur
    
    @State private var BGColourChanged = false
    @State private var imageColourChanged = false
    @State private var sizeChanged = false
    
    var size: CGSize
    var imageScale: Double
    var showBG: Bool
    var firstBGColour: Color
    var secondBGColour: Color
    var changeBGColour: Bool
    var imageName: String
    var firstImgColour: Color
    var secondImgColour: Color
    var changeImgColour: Bool
    var scaleRatio: CGFloat
    var animationSpeed: Double
    var backgroundBlur: CGFloat
    
    init(size: CGSize = CGSize(width: 50, height: 50),
         imageScale: Double = 0.9,
         showBG: Bool = true,
         firstBGColour: Color = .white,
         secondBGColour: Color = .white,
         changeBGColour: Bool = false,
         imageName: String,
         firstImgColour: Color = .white,
         secondImgColour: Color = .white,
         changeImgColour: Bool = false,
         scaleRatio: CGFloat,
         animationSpeed: Double = 0,
         backgroundBlur: CGFloat = 0) {
        self.size = size
        self.imageScale = imageScale
        self.showBG = showBG
        self.firstBGColour = firstBGColour
        self.secondBGColour = secondBGColour
        self.changeBGColour = changeBGColour
        self.imageName = imageName
        self.firstImgColour = firstImgColour
        self.secondImgColour = secondImgColour
        self.changeImgColour = changeImgColour
        self.scaleRatio = scaleRatio
        self.animationSpeed = animationSpeed
        self.backgroundBlur = backgroundBlur
    }
    
    var body: some View {
        ZStack {
            Color.clear
                .if(self.backgroundBlur > 0, transform: { view in
                    view
                        .ignoresSafeArea()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .blur(radius: self.backgroundBlur)
                })
                    
                    if self.showBG {
                    Circle()
                        .frame(width: size.width, height: size.height)
                        .foregroundColor(BGColourChanged ? secondBGColour : firstBGColour)
                        .scaleEffect(sizeChanged ? scaleRatio : 1)
                }
            
            Image(systemName: imageName)
                .font(.system(size: size.height * imageScale))
                .foregroundColor(imageColourChanged ? secondImgColour : firstImgColour)
                .scaleEffect(sizeChanged ? scaleRatio : 1)
        }
        .onAppear() {
            withAnimation(.easeInOut(duration: animationSpeed)) {
                if changeBGColour { BGColourChanged = true }
                if changeImgColour { imageColourChanged = true }
                sizeChanged = true
            }
        }
    }
}



