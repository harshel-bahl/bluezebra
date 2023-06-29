//
//  RecordingAni.swift
//  bluezebra
//
//  Created by Harshel Bahl on 28/06/2023.
//

import SwiftUI

struct RecordingAni: View {
    
    @State private var isRec = false

    let borderColour: Color
    let borderLineWidth: CGFloat
    let buttonColour: Color
    let size: CGSize
    let recAction: (Bool)->()
    
        var body: some View {
                ZStack {
                    RoundedRectangle(cornerRadius: size.height*0.5)
                        .stroke(style: StrokeStyle(lineWidth: self.borderLineWidth, lineCap: .round))
                        .fill(borderColour)

                    RoundedRectangle(cornerRadius: cornerRadius(using: size.width))
                        .fill(buttonColour)
                        .frame(width: recIconSize(using: size.width),
                               height: recIconSize(using: size.height))
                        .animation(.easeOut(duration: 0.125), value: self.isRec)
                        .onTapGesture {
                            isRec.toggle()
                    }
                }
                .frame(width: size.width,
                       height: size.height)
                .onChange(of: isRec) { isRec in
                    recAction(isRec)
                }
        }

        func cornerRadius(using size: CGFloat) -> CGFloat {
            if isRec {
                return size * 0.1
            } else {
                return size * 0.5
            }
        }

        func recIconSize(using size: CGFloat) -> CGFloat {
            isRec ? size * 0.5 : size - (size * 0.18)
        }
}


