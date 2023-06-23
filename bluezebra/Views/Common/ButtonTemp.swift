//
//  ButtonTemp.swift
//  bluezebra
//
//  Created by Harshel Bahl on 21/06/2023.
//

import SwiftUI

struct ButtonTemp: View {
    
    var label: String
    var backgroundColour: Color
    var foregroundColour: Color
    var action: ()->()
    
    var body: some View {
        Button(label) {
            action()
        }
        .padding()
        .background(backgroundColour)
        .foregroundStyle(foregroundColour)
        .clipShape(Capsule())
        .buttonStyle(GrowingButton())
    }
}


struct GrowingButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.2 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
