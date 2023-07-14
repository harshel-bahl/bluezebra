//
//  SheetModifier.swift
//  bluezebra
//
//  Created by Harshel Bahl on 14/07/2023.
//

import SwiftUI

struct SheetModifier<SheetContent: View>: ViewModifier {
    
    @Binding var isPresented: Bool
    
    let BG: Color
    
    let sheetContent: () -> SheetContent
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                ZStack {
                    
                    BG
                    
                    VStack(spacing: 0) {
                        
                        Rectangle()
                            .fill(Color("darkAccent1").opacity(0.75))
                            .frame(width: 35,
                                   height: 5)
                            .cornerRadius(7.5)
                            .edgePadding(top: 7.5,
                                         bottom: 15)
                        
                        sheetContent()
                    }
                }
                .ignoresSafeArea()
            }
    }
}

extension View {
    func sheetModifier<SheetContent: View>(isPresented: Binding<Bool>,
                                           BG: Color,
                                           sheetContent: @escaping () -> SheetContent) -> some View {
        modifier(SheetModifier(isPresented: isPresented,
                               BG: BG,
                               sheetContent: sheetContent))
    }
}
