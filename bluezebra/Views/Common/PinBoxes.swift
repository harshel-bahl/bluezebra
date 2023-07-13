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
    let pinLength: Int
    
    let boxSize: CGSize
    let boxSpacing: CGFloat
    let boxBG: Color
    let boxCR: CGFloat
    let boxBorder: Color
    let boxBorderLength: CGFloat
    let boxShadow: CGFloat
    
    let outerBorder: Bool
    let padding: EdgeInsets
    let outerBG: Color
    let outerCR: CGFloat
    let outerShadow: CGFloat
    
    let character: String
    let characSize: CGFloat
    let characColour: Color
    let characWeight: Font.Weight
    let characOffset: CGFloat
    
    var focus: FocusState<String?>.Binding
    let focusValue: String
    
    let commitAction: (String)->()
    
    init(pin: Binding<String>,
         pinLength: Int = 4,
         boxSize: CGSize = .init(width: 50, height: 50),
         boxSpacing: CGFloat = 25,
         boxBG: Color = Color("background2"),
         boxCR: CGFloat = 5,
         boxBorder: Color = Color("blueAccent1"),
         boxBorderLength: CGFloat = 0.5,
         boxShadow: CGFloat = 0.5,
         outerBorder: Bool = true,
         padding: EdgeInsets = .init(top: 20, leading: 22.5, bottom: 20, trailing: 22.5),
         outerBG: Color = Color("background2"),
         outerCR: CGFloat = 20,
         outerShadow: CGFloat = 2,
         character: String = "*",
         characSize: CGFloat = 47.5,
         characColour: Color = Color("text1"),
         characWeight: Font.Weight = .regular,
         characOffset: CGFloat = 10,
         focus: FocusState<String?>.Binding,
         focusValue: String,
         commitAction: @escaping (String)->()) {
        self._pin = pin
        self.pinLength = pinLength
        
        self.boxSize = boxSize
        self.boxSpacing = boxSpacing
        self.boxBG = boxBG
        self.boxCR = boxCR
        self.boxBorder = boxBorder
        self.boxBorderLength = boxBorderLength
        self.boxShadow = boxShadow
        
        self.outerBorder = outerBorder
        self.padding = padding
        self.outerBG = outerBG
        self.outerCR = outerCR
        self.outerShadow = outerShadow
        
        self.character = character
        self.characSize = characSize
        self.characColour = characColour
        self.characWeight = characWeight
        self.characOffset = characOffset
        
        self.focus = focus
        self.focusValue = focusValue
        
        self.commitAction = commitAction
    }
    
    var body: some View {
        ZStack {
            TextField("", text: $pin.limit(pinLength))
                .keyboardType(.numberPad)
                .frame(width: 1, height: 1)
                .opacity(0.001)
                .blendMode(.screen)
                .focused(focus, equals: focusValue)
            
            pinBoxes
        }
        .onChange(of: pin) { pin in
        if self.pin.count == pinLength {
            commitAction(pin)
        }
    }
    }
    
    var pinBoxes: some View {
        HStack(spacing: boxSpacing) {
            ForEach(0 ..< self.pinLength, id: \.self) { index in
                pinBoxes(index)
            }
        }
        .if(outerBorder == true, transform: { view in
            view
                .padding(padding)
                .background { outerBG }
                .borderModifier(lineWidth: 2,
                                lineColour: boxBorder,
                                cornerRadius: outerCR)
                .shadow(radius: outerShadow)
        })
    }
    
    @ViewBuilder
    func pinBoxes(_ index: Int) -> some View {
        ZStack(alignment: .center) {
            if pin.count > index {
                FixedText(text: character,
                          colour: characColour,
                          fontSize: characSize,
                          fontWeight: characWeight)
                .offset(y: characOffset)
            }
        }
        .frame(width: boxSize.width, height: boxSize.height)
        .background() { boxBG }
        .cornerRadius(boxCR)
        .overlay {
            let status = (focus.wrappedValue == focusValue && pin.count == index)
            
            RoundedRectangle(cornerRadius: boxCR, style: .continuous)
                .stroke(boxBorder, lineWidth: status ? boxBorderLength*4 : boxBorderLength)
                .animation(.easeInOut(duration: 0.15), value: focus.wrappedValue)
        }
        .shadow(radius: boxShadow)
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
