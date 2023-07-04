//
//  ScrollViewList.swift
//  bluezebra
//
//  Created by Harshel Bahl on 27/06/2023.
//

import SwiftUI

struct ScrollViewList<Data: Identifiable, Content: View>: View {
    @State private var activeId: Data.ID?

    let showIndicators: Bool
    let data: [Data]
    let contentView: (Data) -> Content
    
    let iconBackground: Color

    var body: some View {
        ScrollViewReader { proxy in
            ZStack {
                ScrollView(showsIndicators: showIndicators) {
                    VStack {
                        ForEach(data, id: \.id) { element in
                            GeometryReader { geometry in
                                Color.clear
                                    .preference(key: ViewOffsetKey<Data.ID>.self,
                                                value: [ViewOffset(id: element.id,
                                                                   offset: geometry.frame(in: .named("scrollView")).minY)])
                            }
                            self.contentView(element)
                        }
                    }
                    .coordinateSpace(name: "scrollView")
                    .onPreferenceChange(ViewOffsetKey<Data.ID>.self) { viewOffsets in
                        let visibleOffsets = viewOffsets.filter { $0.offset > -1 && $0.offset < UIScreen.main.bounds.height }
                        if let first = visibleOffsets.min(by: { $0.offset < $1.offset }) {
                            activeId = first.id
                        }
                    }
                }
                
                if activeId != data.first?.id {
                    Button(action: {
                        withAnimation {
                            proxy.scrollTo(data.first?.id, anchor: .top)
                        }
                    }) {
                        Image(systemName: "chevron.up")
                            .padding()
                            .background(iconBackground)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                activeId = data.first?.id
            }
        }
    }
}

struct ViewOffset<ID: Hashable>: Equatable {
    let id: ID
    let offset: CGFloat
}

struct ViewOffsetKey<ID: Hashable>: PreferenceKey {
    typealias Value = [ViewOffset<ID>]

    static var defaultValue: Value { [] }

    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.append(contentsOf: nextValue())
    }
}

