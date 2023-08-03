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
    
    let outerBorder: Bool
    let padding: EdgeInsets
    let outerBG: Color
    let outerCR: CGFloat
    let outerShadow: CGFloat
    
    let characSize: CGSize
    let characColour: Color
    
    var focus: FocusState<String?>.Binding
    let focusValue: String
    
    let commitAction: (String)->()
    
    init(pin: Binding<String>,
         pinLength: Int = 4,
         boxSize: CGSize = .init(width: 50, height: 50),
         boxSpacing: CGFloat = 25,
         boxBG: Color = Color("background1"),
         boxCR: CGFloat = 5,
         boxBorder: Color = Color("accent1"),
         boxBorderLength: CGFloat = 0.5,
         outerBorder: Bool = true,
         padding: EdgeInsets = .init(top: 20, leading: 22.5, bottom: 20, trailing: 22.5),
         outerBG: Color = Color("background1"),
         outerCR: CGFloat = 20,
         outerShadow: CGFloat = 2,
         characSize: CGSize = .init(width: 12.5, height: 12.5),
         characColour: Color = Color("text1"),
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
        
        self.outerBorder = outerBorder
        self.padding = padding
        self.outerBG = outerBG
        self.outerCR = outerCR
        self.outerShadow = outerShadow
        
        self.characSize = characSize
        self.characColour = characColour
        
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
                Circle()
                    .fill(characColour)
                    .frame(width: characSize.width, height: characSize.height)
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
