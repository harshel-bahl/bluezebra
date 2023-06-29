//
//  ProgressBar.swift
//  bluezebra
//
//  Created by Harshel Bahl on 28/06/2023.
//

import SwiftUI

struct ProgressBar: View {

    @Binding var progress: CGFloat

    let color: Color
    let size: CGSize
    let cornerRadius: CGFloat
    let animationTime: TimeInterval

    public init(progress: Binding<CGFloat>,
                color: Color,
                size: CGSize,
                cornerRadius: CGFloat,
                animationTime: TimeInterval = 0.3) {
        self._progress = progress
        self.color = color
        self.size = size
        self.cornerRadius = cornerRadius
        self.animationTime = animationTime
    }

    var body: some View {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(color.opacity(0.3))

                Rectangle()
                    .fill(color)
                    .frame(width: min(size.width, size.width * progress))
                    .animation(.linear, value: progress)
            }
            .cornerRadius(self.cornerRadius)
    }
}


