//
//  TextSegmentView.swift
//  bluezebra
//
//  Created by Harshel Bahl on 14/07/2023.
//

import SwiftUI

struct TextSegmentView: View {
    @Binding var selected: Int

    let textNames: [String]
    let elementSize: CGSize
    let textColour: Color?
    let BGColour: Color
    let selectedBGColour: Color
    let elementPadding: EdgeInsets
    let elementSpacing: CGFloat
    let cornerRadius: CGFloat
    let animation: Animation
    
    init(selected: Binding<Int>,
         textNames: [String],
         elementSize: CGSize = .init(width: 80, height: 16),
         textColour: Color = .white,
         BGColour: Color = .gray,
         selectedBGColour: Color = .blue,
         elementPadding: EdgeInsets = .init(top: 7.5, leading: 12.5, bottom: 7.5, trailing: 12.5),
         elementSpacing: CGFloat = 3,
         cornerRadius: CGFloat = 5,
         animation: Animation = .interactiveSpring(response: 0.5,
                                                   dampingFraction: 1,
                                                   blendDuration: 0.25)) {
        self._selected = selected
        self.textNames = textNames
        self.elementSize = elementSize
        self.textColour = textColour
        self.BGColour = BGColour
        self.selectedBGColour = selectedBGColour
        self.elementPadding = elementPadding
        self.elementSpacing = elementSpacing
        self.cornerRadius = cornerRadius
        self.animation = animation
    }
    
    var body: some View {
        HStack(spacing: elementSpacing) {
            ForEach(0 ..< textNames.count) { index in
                
                Text(textNames[index])
                    .font(.system(size: elementSize.height))
                    .frame(width: elementSize.width,
                           height: elementSize.height)
                    .foregroundColor(textColour)
                    .onTapGesture {
                            selected = index
                    }
                
                    .tag(index)
                    .padding(elementPadding)
                    .background() {
                        if selected == index {
                            selectedBGColour
                        } else {
                            BGColour
                        }
                    }
                    .cornerRadius(cornerRadius)
            }
        }
        .animation(animation, value: selected)
        .padding(1)
        .background() {
            BGColour
        }
        .cornerRadius(cornerRadius)
    }
}

