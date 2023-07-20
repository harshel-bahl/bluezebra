//
//  SystemIcon.swift
//  bluezebra
//
//  Created by Harshel Bahl on 04/07/2023.
//

import SwiftUI

struct SystemIcon<ClipShape: Shape>: View {

    let systemName: String
    let size: CGSize
    let colour: Color
    let padding: EdgeInsets?
    let BGColour: Color?
    let applyClip: Bool
    let clipShape: ClipShape
    let shadow: CGFloat
    
    let buttonAction: (()->Void)?
    
    init(systemName: String,
         size: CGSize = .init(width: 25, height: 25),
         colour: Color,
         padding: EdgeInsets? = nil,
         BGColour: Color? = nil,
         applyClip: Bool = false,
         clipShape: ClipShape = Circle(),
         shadow: CGFloat = 0,
         buttonAction: (() -> Void)? = nil) {
        self.systemName = systemName
        self.size = size
        self.colour = colour
        self.padding = padding
        self.BGColour = BGColour
        self.shadow = shadow
        self.applyClip = applyClip
        self.clipShape = clipShape
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        
        if let buttonAction = buttonAction {
            Button(action: {
                buttonAction()
            }, label: {
                icon
            })
        } else {
            icon
        }  
    }
    
    var icon: some View {
        Image(systemName: systemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size.width,
                   height: size.height)
            .foregroundColor(colour)
            .if(BGColour != nil, transform: { view in
                view
                    .background() { BGColour }
            })
                .if(applyClip == true, transform: { view in
                    view
                        .clipShape(clipShape)
                })
                    .shadow(radius: shadow)
                    .if(padding != nil, transform: { view in
                        view
                            .padding(padding!)
                    })
    }
}

let shit = SystemIcon(systemName: "person",
                      size: .init(width: 10, height: 10),
                      colour: .white)
