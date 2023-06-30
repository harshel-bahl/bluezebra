//
//  FixedText.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/06/2023.
//

import SwiftUI

struct FixedText: View {
    
    var text: String
    var colour: Color
    let fontSize: CGFloat
    var size: CGSize?
    var fontWeight: Font.Weight?
    var fontDesign: Font.Design?
    let lineLimit: Int?
    
    init(text: String,
         colour: Color,
         fontSize: CGFloat,
         size: CGSize? = nil,
         fontWeight: Font.Weight? = nil,
         fontDesign: Font.Design? = nil,
         lineLimit: Int? = nil) {
        self.text = text
        self.colour = colour
        self.fontSize = fontSize
        self.size = size
        self.fontWeight = fontWeight
        self.fontDesign = fontDesign
        self.lineLimit = lineLimit
    }
    
    var body: some View {
        Text(text)
            .font(.system(size: fontSize,
                          weight: fontWeight,
                          design: fontDesign))
            .frame(width: size?.width,
                   height: size?.height)
            .foregroundColor(colour)
            .lineLimit(lineLimit)
    }
}


