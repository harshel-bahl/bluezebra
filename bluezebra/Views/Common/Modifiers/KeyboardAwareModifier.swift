//
//  KeyboardAwareModifier.swift
//  bluezebra
//
//  Created by Harshel Bahl on 08/04/2023.
//

import SwiftUI
import Combine

internal struct KeyboardAwareModifier: ViewModifier {
    
    @EnvironmentObject var SP: ScreenProperties
    
    @State private var keyboardHeight: CGFloat = 0
    
    let bottomSAI: Bool
    
    let paddingAnimation: Animation
    
    private var keyboardHeightPublisher: AnyPublisher<CGFloat, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
                .map { $0.height },
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) }
        ).eraseToAnyPublisher()
    }
    
    public func body(content: Content) -> some View {
        content
            .if(bottomSAI == true, transform: { view in
                view
                    .padding(.bottom, (keyboardHeight==0 ? 0 : keyboardHeight))
                    .background() { Color.red }
            })
                .if(bottomSAI == false, transform: { view in
                    view
                        .padding(.bottom, (keyboardHeight==0 ? 0 : keyboardHeight))
                })
                    .onReceive(keyboardHeightPublisher) { height in
                withAnimation(paddingAnimation) {
                    keyboardHeight = height
                }
            }
            .ignoresSafeArea()
    }
}

internal extension View {
    
    func keyboardAwarePadding(bottomSAI: Bool = false,
                              paddingAnimation: Animation = .linear(duration: 0.25)) -> some View {
        modifier(KeyboardAwareModifier(bottomSAI: bottomSAI,
                                       paddingAnimation: paddingAnimation))
    }
    
}
