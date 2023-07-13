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
    @State private var showImage = false
    @State private var sizeChanged = false
    @State private var BGOpacity = false
    
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
    var mainAniDur: Double
    var showImgAniDur: Double
    var opacityAniDur: Double
    var opacity: CGFloat
    
    init(size: CGSize = CGSize(width: 80, height: 80),
         imageScale: Double = 0.75,
         showBG: Bool = true,
         firstBGColour: Color = .white,
         secondBGColour: Color = .white,
         changeBGColour: Bool = true,
         imageName: String,
         firstImgColour: Color = .white,
         secondImgColour: Color = .white,
         changeImgColour: Bool = true,
         scaleRatio: CGFloat = 2,
         mainAniDur: Double = 2,
         showImgAniDur: CGFloat = 0.25,
         opacityAniDur: CGFloat = 0.3,
         opacity: CGFloat = 0.9) {
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
        self.mainAniDur = mainAniDur
        self.showImgAniDur = showImgAniDur
        self.opacityAniDur = opacityAniDur
        self.opacity = opacity
    }
    
    var body: some View {
        ZStack {
            if opacity > 0 {
                Color.gray
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .opacity(BGOpacity ? opacity : 0)
            }
            
            if showImage {
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
        
        }
        .onAppear() {
            
            if showImgAniDur > 0 {
                withAnimation(.easeInOut(duration: showImgAniDur).delay(showImgAniDur)) {
                    showImage = true
                }
            } else {
                showImage = true
            }
            
            withAnimation(.easeInOut(duration: mainAniDur).delay(mainAniDur*0.25)) {
                if changeBGColour { BGColourChanged = true }
                if changeImgColour { imageColourChanged = true }
                sizeChanged = true
            }
            
            withAnimation(.easeInOut(duration: opacityAniDur)) {
                if opacity > 0 { BGOpacity = true }
            }
        }
    }
}



