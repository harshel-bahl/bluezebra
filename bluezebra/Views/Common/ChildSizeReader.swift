//
//  ChildSizeReader.swift
//  bluezebra
//
//  Created by Harshel Bahl on 27/05/2023.
//

import SwiftUI

struct ChildSizeReader<Content: View>: View {
    
    @Binding var size: CGSize
    let content: () -> Content
    
    var body: some View {
        ZStack {
            content()
                .background() {
                    GeometryReader { proxy in
                        Color.clear
                            .preference(key: SizePreferenceKey.self, value: proxy.size)
                    }
                }
        }
        .onPreferenceChange(SizePreferenceKey.self) { preferences in
            self.size = preferences
        }
    }
}

struct SizePreferenceKey : PreferenceKey {
    
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
    
}

