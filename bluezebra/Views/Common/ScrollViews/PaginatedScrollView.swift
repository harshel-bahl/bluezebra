//
//  PaginatedScrollView.swift
//  bluezebra
//
//  Created by Harshel Bahl on 26/06/2023.
//

import SwiftUI

struct PaginatedScrollView<Content: View>: View {
    
    @EnvironmentObject var SP: ScreenProperties
    
    let content: [ViewKey: (ScrollViewProxy) -> Content]
    let backgroundColour: Color
    
    var body: some View {
        
        ZStack {
            
            backgroundColour
            
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    ForEach(content.sorted(by: { $0.key.id < $1.key.id }), id: \.key) { key, page in
                        page(proxy)
                            .id(key)
                            .frame(height: SP.screenHeight)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .frame(height: SP.screenHeight)
    }
}

struct ViewKey: Hashable {
    let id: Int
}


