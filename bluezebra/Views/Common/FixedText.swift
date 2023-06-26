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
    var size: CGFloat
    var fontWeight: Font.Weight?
    var fontDesign: Font.Design?
    
    init(text: String,
         colour: Color,
         size: CGFloat,
         fontWeight: Font.Weight? = nil,
         fontDesign: Font.Design? = nil) {
        self.text = text
        self.colour = colour
        self.size = size
        self.fontWeight = fontWeight
        self.fontDesign = fontDesign
    }
    
    var body: some View {
        Text(text)
            .foregroundColor(colour)
            .font(.system(size: size,
                          weight: fontWeight,
                          design: fontDesign))
    }
}


