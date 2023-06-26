//
//  BorderOverlay.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/06/2023.
//

import SwiftUI

struct BorderOverlay: ViewModifier {
    
    let lineWidth: CGFloat
    let lineColour: Color
    let cornerRadius: CGFloat?
    let padding: CGFloat?
    let shadowRadius: CGFloat?
    
    init(lineWidth: CGFloat,
         lineColour: Color,
         cornerRadius: CGFloat? = nil,
         padding: CGFloat? = nil,
         shadowRadius: CGFloat? = nil) {
        self.lineWidth = lineWidth
        self.lineColour = lineColour
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.shadowRadius = shadowRadius
    }
    
    func body(content: Content) -> some View {
        content
            .padding(padding ?? 0)
            .cornerRadius(cornerRadius ?? 0)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius ?? 0)
                    .stroke(lineColour, lineWidth: lineWidth)
            )
            .shadow(radius: shadowRadius ?? 0)
    }
}

extension View {
    func borderModifier(lineWidth: CGFloat,
                        lineColour: Color,
                        cornerRadius: CGFloat? = nil,
                        padding: CGFloat? = nil,
                        shadowRadius: CGFloat? = nil) -> some View {
        modifier(BorderOverlay(lineWidth: lineWidth,
                               lineColour: lineColour,
                              cornerRadius: cornerRadius,
                              padding: padding,
                              shadowRadius: shadowRadius))
    }
}

