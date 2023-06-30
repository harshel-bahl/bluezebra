//
//  PinBoxes.swift
//  bluezebra
//
//  Created by Harshel Bahl on 05/06/2023.
//

import SwiftUI

struct PinBoxes: View {
    
    @EnvironmentObject var SP: ScreenProperties
    
    @Binding var pin: String
    
    @FocusState var focused: Bool
    
    let delayFocus: Bool
    let delayFocusLength: Float
    let pinLength: Int
    let characterSize: CGFloat
    let characterColour: Color
    let characterWeight: Font.Weight
    let boxSize: CGSize
    let commitAction: (String)->()
    
    init(pin: Binding<String>,
         delayFocus: Bool,
         delayFocusLength: Float,
         pinLength: Int,
         characterSize: CGFloat,
         characterColour: Color,
         characterWeight: Font.Weight,
         boxSize: CGSize,
         commitAction: @escaping (String)->()) {
        self._pin = pin
        self.delayFocus = delayFocus
        self.delayFocusLength = delayFocusLength
        self.pinLength = pinLength
        self.characterSize = characterSize
        self.characterColour = characterColour
        self.characterWeight = characterWeight
        self.boxSize = boxSize
        self.commitAction = commitAction
    }
    
    var body: some View {
        ZStack {
            TextField("", text: $pin.limit(4))
                .keyboardType(.numberPad)
                .frame(width: 1, height: 1)
                .opacity(0.001)
                .blendMode(.screen)
                .focused($focused)
                .if(self.delayFocus, transform: { view in
                    view
                        .onAppear() {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                focused = true
                            })
                        }
                })
                    
                    pinBoxes
        }
    }
    
    var pinBoxes: some View {
        HStack(spacing: 0) {
            ForEach(0 ..< self.pinLength, id: \.self) { index in
                
                if index != 0 { Spacer() }
                
                pinBoxes(index)
                
                if index != pinLength-1 { Spacer() }
            }
        }
        .onChange(of: pin) { pin in
            if self.pin.count == 4 {
            }
        }
    }
    
    @ViewBuilder
    func pinBoxes(_ index: Int) -> some View {
        ZStack(alignment: .center) {
            if pin.count > index {
                FixedText(text: "*",
                          colour: characterColour,
                          fontSize: characterSize,
                          fontWeight: characterWeight)
                .offset(y: 7.5)
            }
        }
        .frame(width: boxSize.width, height: boxSize.height)
        .background() { Color("background2") }
        .cornerRadius(5)
        .overlay {
            let status = (focused && pin.count == index)
            
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(Color("blueAccent1"), lineWidth: status ? 2 : 0.5)
                .animation(.easeInOut(duration: 0.2), value: focused)
        }
        .shadow(radius: 1)
    }
}

extension Binding where Value == String {
    
    func limit(_ length: Int) -> Self {
        if self.wrappedValue.count > length {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(length))
            }
        }
        
        return self
    }
}
