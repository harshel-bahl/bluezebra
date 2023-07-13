//
//  PaginatedScrollView.swift
//  bluezebra
//
//  Created by Harshel Bahl on 26/06/2023.
//

import SwiftUI

struct PaginatedScrollView: View {
    
    @EnvironmentObject var SP: ScreenProperties
    
    let backgroundColour: Color
    let content: [ViewKey: (ScrollViewProxy) -> AnyView]
    
    var body: some View {
        ZStack {
            backgroundColour
            
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(content.sorted(by: { $0.key.id < $1.key.id }), id: \.key) { key, page in
                            
                            SafeAreaScreen(BGColour: backgroundColour) {
                                page(proxy)
                            }
                            .frame(height: SP.screenHeight)
                            .id(key.id)
                        }
                    }
                }
                .scrollDisabled(true)
            }
            .ignoresSafeArea()
        }
    }
    
    static func scrollTo(pageID: Int,
                         proxy: ScrollViewProxy) {
        proxy.scrollTo(pageID, anchor: .top)
    }
}

struct ViewKey: Hashable {
    let id: Int
}


