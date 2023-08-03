//
//  ButtonAni.swift
//  bluezebra
//
//  Created by Harshel Bahl on 21/06/2023.
//

import SwiftUI

struct ButtonAni: View {
    
    let label: String?
    let fontSize: CGFloat?
    let fontWeight: Font.Weight?
    
    let imageName: String?
    let imageSize: CGSize?
    
    let buttonSize: CGSize?
    let foregroundColour: Color
    let BGColour: Color
    let padding: CGFloat?
    let cornerRadius: CGFloat
    let scale: CGFloat
    let shadow: CGFloat
    
    let action: ()->()
    
    init(label: String? = nil,
         fontSize: CGFloat? = nil,
         fontWeight: Font.Weight? = nil,
         imageName: String? = nil,
         imageSize: CGSize? = nil,
         foregroundColour: Color,
         buttonSize: CGSize? = .init(width: 200, height: 50),
         BGColour: Color,
         padding: CGFloat? = nil,
         cornerRadius: CGFloat = 10,
         scale: CGFloat = 0.9,
         shadow: CGFloat = 0,
         action: @escaping () -> Void) {
        self.label = label
        self.fontSize = fontSize
        self.fontWeight = fontWeight
        self.imageName = imageName
        self.imageSize = imageSize
        self.foregroundColour = foregroundColour
        self.buttonSize = buttonSize
        self.BGColour = BGColour
        self.padding = padding
        self.cornerRadius = cornerRadius
        self.scale = scale
        self.shadow = shadow
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            if let label = self.label,
               let fontSize = self.fontSize {
                
                FixedText(text: label,
                          colour: self.foregroundColour,
                          fontSize: fontSize,
                          fontWeight: self.fontWeight)
                
            } else if let imageName = imageName,
                      let imageSize = imageSize {
                
                Image(systemName: imageName)
                    .frame(width: imageSize.width,
                           height: imageSize.height)
                    .foregroundColor(self.foregroundColour)
                
            }
        })
        .buttonStyle(ButtonStyle1(BGColour: BGColour,
                                  textColour: .black,
                                  buttonSize: buttonSize,
                                  padding: padding,
                                  cornerRadius: cornerRadius,
                                  scale: self.scale,
                                  shadow: self.shadow))
    }
}


struct ButtonStyle1: ButtonStyle {
    
    let BGColour: Color
    let textColour: Color
    let buttonSize: CGSize?
    let padding: CGFloat?
    let cornerRadius: CGFloat
    let scale: CGFloat
    let shadow: CGFloat
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(self.textColour)
            .if(padding != nil, transform: { view in
                view
                    .padding(self.padding!)
            })
            .frame(width: buttonSize?.width, height: buttonSize?.height)
            .cornerRadius(self.cornerRadius)
            .background(RoundedRectangle(cornerRadius: self.cornerRadius)
                .foregroundColor(configuration.isPressed ? self.BGColour.opacity(0.75) : self.BGColour))
            .scaleEffect(configuration.isPressed ? self.scale : 1.0)
            .shadow(radius: self.shadow)
            .animation(.interpolatingSpring(mass: 0.5, stiffness: 50, damping: 5), value: configuration.isPressed)
    }
}


