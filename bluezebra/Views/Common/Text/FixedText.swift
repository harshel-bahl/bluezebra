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
    let lineLimit: ClosedRange<Int>?
    let padding: EdgeInsets?
    let multilineAlignment: TextAlignment?
    let pushText: Alignment?
    
    init(text: String,
         colour: Color,
         fontSize: CGFloat,
         size: CGSize? = nil,
         fontWeight: Font.Weight? = nil,
         fontDesign: Font.Design? = nil,
         lineLimit: ClosedRange<Int>? = nil,
         padding: EdgeInsets? = nil,
         multilineAlignment: TextAlignment? = nil,
         pushText: Alignment? = nil) {
        self.text = text
        self.colour = colour
        self.fontSize = fontSize
        self.size = size
        self.fontWeight = fontWeight
        self.fontDesign = fontDesign
        self.lineLimit = lineLimit
        self.padding = padding
        self.multilineAlignment = multilineAlignment
        self.pushText = pushText
    }
    
    var body: some View {
        Text(text)
            .font(.system(size: fontSize,
                          weight: fontWeight,
                          design: fontDesign))
            .frame(width: size?.width,
                   height: size?.height)
            .foregroundColor(colour)
            .if(lineLimit != nil, transform: { view in
                view
                    .lineLimit(lineLimit!)
            })
                .if(padding != nil, transform: { view in
                    view
                        .padding(padding!)
                })
                    .if(multilineAlignment != nil, transform: { view in
                        view
                            .multilineTextAlignment(multilineAlignment!)
                    })
                        .if(pushText != nil, transform: { view -> AnyView in
                            
                            switch(pushText!) {
                            case .top:
                                return AnyView(VStack(spacing: 0) {
                                    view
                                    Spacer(minLength: 0)
                                })
                            case .bottom:
                                return AnyView(VStack(spacing: 0) {
                                    Spacer(minLength: 0)
                                    view
                                })
                            case .leading:
                                return AnyView(HStack(spacing: 0) {
                                    view
                                    Spacer(minLength: 0)
                                })
                            case .trailing:
                                return AnyView(HStack(spacing: 0) {
                                    Spacer(minLength: 0)
                                    view
                                })
                            default:
                                return AnyView(view)
                            }
                        })
    }
}


