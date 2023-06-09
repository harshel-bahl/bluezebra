//
//  ScreenProperties.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 07/02/2023.
//

import Foundation

class ScreenProperties: ObservableObject {
    @Published var height: CGFloat
    @Published var width: CGFloat
    @Published var topSafeAreaInset: CGFloat
    @Published var bottomSafeAreaInset: CGFloat
    @Published var safeAreaHeight: CGFloat 
    
    init(height: CGFloat = 0, width: CGFloat = 0, topSafeAreaInset: CGFloat = 0, bottomSafeAreaInset: CGFloat = 0) {
        self.height = height
        self.width = width
        self.topSafeAreaInset = topSafeAreaInset
        self.bottomSafeAreaInset = bottomSafeAreaInset
        self.safeAreaHeight = height - topSafeAreaInset - bottomSafeAreaInset
    }
}
