//
//  SafeAreaScreen.swift
//  bluezebra
//
//  Created by Harshel Bahl on 07/07/2023.
//

import SwiftUI

struct SafeAreaScreen<Content: View>: View {
    
    @EnvironmentObject var SP: ScreenProperties
    
    let BGColour: Color
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        ZStack {
            
            BGColour
            
            content()
                .padding(EdgeInsets(top: SP.topSAI,
                                    leading: 0,
                                    bottom: SP.bottomSAI,
                                    trailing: 0))
        }
        .ignoresSafeArea()
    }
}

