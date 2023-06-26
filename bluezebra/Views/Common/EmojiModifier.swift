//
//  EmojiModifier.swift
//  bluezebra
//
//  Created by Harshel Bahl on 08/04/2023.
//

import SwiftUI

/// Modifies the content if text contains emoji
internal struct EmojiModifier: ViewModifier {
    
    public let text: String
    public let defaultFont: Font
    
    private var font: Font? {
        var _font: Font = defaultFont
        if text.containsOnlyEmoji {
            let count = text.count
            switch count {
            case 1: _font = .system(size: 50)
            case 2: _font = .system(size: 38)
            case 3: _font = .system(size: 25)
            default: _font = defaultFont
            }
        }
        return _font
    }
    
    public func body(content: Content) -> some View {
        content.font(font)
    }
    
}

extension Character {
    
    var isSimpleEmoji: Bool {
            guard let firstScalar = unicodeScalars.first else { return false }
            return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
        }
    
    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }

    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}

extension String {
    var containsOnlyEmoji: Bool { !isEmpty && !contains { !$0.isEmoji } }
}
