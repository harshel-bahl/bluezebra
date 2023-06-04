//
//  TextCellStyle.swift
//  bluezebra
//
//  Created by Harshel Bahl on 08/04/2023.
//

import Foundation
import SwiftUI

struct TextCellStyle {
    let textColor: Color
    let font: Font
    let fontWeight: Font.Weight
    let padding: CGFloat
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let borderColor: Color
    let borderWidth: CGFloat
    let shadowRadius: CGFloat
    let shadowColor: Color
    let roundedCorners: UIRectCorner
    
    init(textColor: Color = .white,
         font: Font = .body,
         fontWeight: Font.Weight = .regular,
         padding: CGFloat = 10,
         backgroundColor: Color = Color.accentColor,
         cornerRadius: CGFloat = 8,
         borderColor: Color = .clear,
         borderWidth: CGFloat = 1,
         shadowRadius: CGFloat = 3,
         shadowColor: Color = .secondary,
         roundedCorners: UIRectCorner = .allCorners) {
        self.textColor = textColor
        self.font = font
        self.fontWeight = fontWeight
        self.padding = padding
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.shadowRadius = shadowRadius
        self.shadowColor = shadowColor
        self.roundedCorners = roundedCorners
    }
}
