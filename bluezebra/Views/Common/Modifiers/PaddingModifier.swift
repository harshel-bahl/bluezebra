//
//  PaddingModifier.swift
//  bluezebra
//
//  Created by Harshel Bahl on 07/07/2023.
//

import SwiftUI

struct PaddingModifier: ViewModifier {
    
    let edgeInsets: EdgeInsets
    
    func body(content: Content) -> some View {
        content
            .padding(edgeInsets)
    }
}

extension View {
    func edgePadding(top: CGFloat = 0,
                     bottom: CGFloat = 0,
                     leading: CGFloat = 0,
                     trailing: CGFloat = 0) -> some View {
        modifier(PaddingModifier(edgeInsets: .init(top: top,
                                                   leading: leading,
                                                   bottom: bottom,
                                                   trailing: trailing)))
    }
}

