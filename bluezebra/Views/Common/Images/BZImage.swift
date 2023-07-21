//
//  BZImage.swift
//  bluezebra
//
//  Created by Harshel Bahl on 21/07/2023.
//

import SwiftUI

struct BZImage: View {
    
    let uiImage: UIImage
    
    let aspectRatio: ContentMode
    let height: CGFloat?
    let width: CGFloat?
    let BG: Color?
    let cornerRadius: CGFloat?
    
    init(uiImage: UIImage,
         aspectRatio: ContentMode = .fit,
         height: CGFloat? = nil,
         width: CGFloat? = nil,
         BG: Color? = nil,
         cornerRadius: CGFloat? = nil) {
        self.uiImage = uiImage
        self.aspectRatio = aspectRatio
        self.height = height
        self.width = width
        self.BG = BG
        self.cornerRadius = cornerRadius
    }
    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: aspectRatio)
            .frame(width: self.width, height: self.height)
            .background { BG }
            .cornerRadius(cornerRadius ?? 0)
    }
}

