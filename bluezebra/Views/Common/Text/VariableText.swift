//
//  VariableText.swift
//  bluezebra
//
//  Created by Harshel Bahl on 28/06/2023.
//

import SwiftUI

struct VariableText: View {
    
    var text: String
    var colour: Color
    let font: Font
    var size: CGSize?
    var fontWeight: Font.Weight?
    let lineLimit: Int?
    
    init(text: String,
         colour: Color,
         font: Font,
         size: CGSize? = nil,
         fontWeight: Font.Weight? = nil,
         lineLimit: Int? = nil) {
        self.text = text
        self.colour = colour
        self.font = font
        self.size = size
        self.fontWeight = fontWeight
        self.lineLimit = lineLimit
    }
    
    var body: some View {
        Text(text)
            .font(font)
            .fontWeight(fontWeight)
            .frame(width: size?.width,
                   height: size?.height)
            .foregroundColor(colour)
            .lineLimit(lineLimit)
    }
}

