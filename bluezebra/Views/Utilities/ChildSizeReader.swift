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

//struct SizePreferenceKey: PreferenceKey {
//    typealias Value = CGSize
//    static var defaultValue: Value = .zero
//
//    static func reduce(value _: inout Value, nextValue: () -> Value) {
//        _ = nextValue()
//    }
//}

struct HeightPreferenceKey : PreferenceKey {
    
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
    
}

struct WidthPreferenceKey : PreferenceKey {
    
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
    
}

struct SizePreferenceKey : PreferenceKey {
    
    static var defaultValue: CGSize = .zero
    
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
    
}

extension View {
    
    func readWidth() -> some View {
        background(GeometryReader {
            Color.clear.preference(key: WidthPreferenceKey.self, value: $0.size.width)
        })
    }
    
    func readHeight() -> some View {
        background(GeometryReader {
            Color.clear.preference(key: HeightPreferenceKey.self, value: $0.size.height)
        })
    }
    
    func onWidthChange(perform action: @escaping (CGFloat) -> Void) -> some View {
        onPreferenceChange(WidthPreferenceKey.self) { width in
            action(width)
        }
    }
    
    func onHeightChange(perform action: @escaping (CGFloat) -> Void) -> some View {
        onPreferenceChange(HeightPreferenceKey.self) { height in
            action(height)
        }
    }
    
    func readSize() -> some View {
        background(GeometryReader {
            Color.clear.preference(key: SizePreferenceKey.self, value: $0.size)
        })
    }
    
    func onSizeChange(perform action: @escaping (CGSize) -> Void) -> some View {
        onPreferenceChange(SizePreferenceKey.self) { size in
            action(size)
        }
    }
    
}
