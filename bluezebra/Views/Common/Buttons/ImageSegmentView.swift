//
//  ImageSegmentView.swift
//  bluezebra
//
//  Created by Harshel Bahl on 14/07/2023.
//

import SwiftUI

struct ImageSegmentView: View {
    @Binding var selected: Int
    
    let imageNames: [String]
    let unselectedImgColour: Color
    let selectedImgColour: Color
    let elementSize: CGSize
    let BGColour: Color
    let selectedBGColour: Color
    let elementPadding: EdgeInsets
    let elementSpacing: CGFloat
    let cornerRadius: CGFloat
    let animation: Animation
    
    init(selected: Binding<Int>,
         imageNames: [String],
         unselectedImgColour: Color = .gray,
         selectedImgColour: Color = .white,
         elementSize: CGSize = .init(width: 15, height: 15),
         BGColour: Color,
         selectedBGColour: Color = .blue,
         elementPadding: EdgeInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10),
         elementSpacing: CGFloat = 3,
         cornerRadius: CGFloat = 7.5,
         animation: Animation = .interactiveSpring(response: 0.5,
                                                   dampingFraction: 1,
                                                   blendDuration: 0.25)) {
        self._selected = selected
        self.imageNames = imageNames
        self.unselectedImgColour = unselectedImgColour
        self.selectedImgColour = selectedImgColour
        self.elementSize = elementSize
        self.BGColour = BGColour
        self.selectedBGColour = selectedBGColour
        self.elementPadding = elementPadding
        self.elementSpacing = elementSpacing
        self.cornerRadius = cornerRadius
        self.animation = animation
    }
    
    var body: some View {
        HStack(spacing: elementSpacing) {
            ForEach(0 ..< imageNames.count) { index in
                Image(systemName: imageNames[index])
                    .frame(width: elementSize.width,
                           height: elementSize.height)
                    .foregroundColor(selected == index ? selectedImgColour : unselectedImgColour)
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


