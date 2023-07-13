//
//  SimpleScrollView.swift
//  bluezebra
//
//  Created by Harshel Bahl on 05/07/2023.
//

import SwiftUI

struct SimpleScrollView<Content: View>: View {
    
    let showIndicators: Bool
    let data: [Data]
    let contentView: (Data) -> Content
    
    let iconBackground: Color
    
    var body: some View {
        ZStack {
            ScrollView(showsIndicators: showIndicators) {
                LazyVStack(spacing: 0) {
                    ForEach(data, id: \.self) { element in
                        self.contentView(element)
                    }
                }
            }
        }
    }
}
