//
//  CustomSegmentAni.swift
//  bluezebra
//
//  Created by Harshel Bahl on 29/06/2023.
//

import SwiftUI

struct CustomSegmentAni: View {
    
    @Binding var selected: Int

    let imageNames: [String]?
    let selectedImgColour: Color?
    let textNames: [String]?
    let elementSize: CGSize?
    let selectedTextColour: Color?
    let BGColour: Color
    let selectedBGColour: Color
    let BGScale: CGFloat
    let elementPadding: CGFloat
    let cornerRadius: CGFloat
    let color = Color.red
    
    init(selected: Binding<Int>,
         imageNames: [String]? = nil,
         selectedImgColour: Color? = nil,
         textNames: [String]? = nil,
         elementSize: CGSize? = nil,
         selectedTextColour: Color? = nil,
         BGScale: CGFloat = 1.5,
         BGColour: Color,
         selectedBGColour: Color,
         elementPadding: CGFloat = 0,
         cornerRadius: CGFloat) {
        self._selected = selected
        self.imageNames = imageNames
        self.selectedImgColour = selectedImgColour
        self.textNames = textNames
        self.elementSize = elementSize
        self.selectedTextColour = selectedTextColour
        self.BGScale = BGScale
        self.BGColour = BGColour
        self.selectedBGColour = selectedBGColour
        self.elementPadding = elementPadding
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        
        if let textNames = textNames,
           let elementSize = self.elementSize {
            HStack(spacing: elementPadding) {
                ForEach(0 ..< textNames.count) { index in
                    
                    ZStack {
                        Rectangle()
                            .fill(selectedBGColour)
                            .opacity(selected==index ? 1 : 0.025)
                            .frame(width: elementSize.width * self.BGScale,
                                   height: elementSize.height * self.BGScale)
                            .cornerRadius(cornerRadius)
                        
                        Text(textNames[index])
                            .font(.system(size: elementSize.height))
                            .frame(width: elementSize.width,
                                   height: elementSize.height)
                            .foregroundColor(selectedImgColour)
                            .onTapGesture {
                                withAnimation(.interactiveSpring(response: 0.2,
                                                                 dampingFraction: 1,
                                                                 blendDuration: 0.25)) {
                                    selected = index
                                }
                            }
                    }
                    .tag(index)
                }
            }
            .padding(2)
            .background() {
                BGColour
            }
            .cornerRadius(cornerRadius)
        } else if let imageNames = self.imageNames,
                  let elementSize = self.elementSize {
            HStack(spacing: elementPadding) {
                ForEach(0 ..< imageNames.count) { index in
                    
                    ZStack {
                        Rectangle()
                            .fill(selectedBGColour)
                            .opacity(selected==index ? 1 : 0.025)
                            .frame(width: elementSize.width * self.BGScale,
                                   height: elementSize.height * self.BGScale)
                            .cornerRadius(cornerRadius)
                        
                        Image(systemName: imageNames[index])
                            .frame(width: elementSize.width,
                                   height: elementSize.height)
                            .foregroundColor(selectedImgColour)
                            .onTapGesture {
                                withAnimation(.interactiveSpring(response: 0.2,
                                                                 dampingFraction: 1,
                                                                 blendDuration: 0.25)) {
                                    selected = index
                                }
                            }
                    }
                    .tag(index)
                }
            }
            .padding(2)
            .background() {
                BGColour
            }
            .cornerRadius(cornerRadius)
        }
    }
}

