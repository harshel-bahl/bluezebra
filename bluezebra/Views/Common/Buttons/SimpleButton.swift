//
//  SimpleButton.swift
//  bluezebra
//
//  Created by Harshel Bahl on 03/08/2023.
//

import SwiftUI

struct SimpleButton: View {
    
    let label: String
    let fontSize: CGFloat
    let fontWeight: Font.Weight?
    let foregroundColour: Color
    
    let BGColour: Color
    let buttonSize: CGSize
    let cornerRadius: CGFloat
    let shadow: CGFloat
    
    let action: ()->()
    
    init(label: String,
         fontSize: CGFloat = 18,
         fontWeight: Font.Weight?,
         foregroundColour: Color = .white,
         BGColour: Color = Color("accent1"),
         buttonSize: CGSize = .init(width: 150, height: 30),
         cornerRadius: CGFloat = 15,
         shadow: CGFloat = 0,
         action: @escaping () -> Void) {
        self.label = label
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.foregroundColour = foregroundColour
        self.BGColour = BGColour
        self.buttonSize = buttonSize
        self.cornerRadius = cornerRadius
        self.shadow = shadow
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            
            FixedText(text: label,
                      colour: foregroundColour,
                      fontSize: fontSize,
                      fontWeight: fontWeight)
            .frame(width: buttonSize.width,
                   height: buttonSize.height)
            .background() { BGColour }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(radius: shadow)
        })
    }
}

