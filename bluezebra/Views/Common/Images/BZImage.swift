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
    let width: CGFloat?
    let height: CGFloat?
    let BG: Color?
    let cornerRadius: CGFloat?
    
    init(uiImage: UIImage,
         aspectRatio: ContentMode = .fit,
         width: CGFloat? = nil,
         height: CGFloat? = nil,
         BG: Color? = nil,
         cornerRadius: CGFloat? = nil) {
        self.uiImage = uiImage
        self.aspectRatio = aspectRatio
        self.width = width
        self.height = height
        self.BG = BG
        self.cornerRadius = cornerRadius
    }
    var body: some View {
        Image(uiImage: uiImage)
            .resizable()
            .aspectRatio(contentMode: aspectRatio)
            .frame(width: self.width, height: self.height)
            .background { BG }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius ?? 0))
    }
}

