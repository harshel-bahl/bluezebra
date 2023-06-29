//
//  ReactionAni.swift
//  bluezebra
//
//  Created by Harshel Bahl on 28/06/2023.
//

import SwiftUI

struct ReactionView: View {
    
    @Binding var showView: Bool
    
    private var icons: [String] // icons must be different or button animation will operate multiple times
    private var iconSize: CGFloat
    private var iconHorPadding: CGFloat
    private var iconVerPadding: CGFloat
    private let containerWidth: CGFloat
    private let containerHeight: CGFloat
    private let aniOffset: CGFloat
    private let aniDegrees: Double
    private let backgroundColour: Color
    private let pressAction: (String)->()
    
    init(showView: Binding<Bool>,
         icons: [String],
         iconSize: CGFloat,
         iconHorPadding: CGFloat,
         iconVerPadding: CGFloat,
         aniOffset: CGFloat = 0,
         aniDegrees: Double = 0,
         backgroundColour: Color,
         pressAction: @escaping (String)->()) {
        self._showView = showView
        self.icons = icons
        self.iconSize = iconSize
        self.iconHorPadding = iconHorPadding
        self.iconVerPadding = iconVerPadding
        self.containerWidth = iconSize * CGFloat(integerLiteral: icons.count) + iconHorPadding * CGFloat(integerLiteral: icons.count + 1)
        self.containerHeight = iconSize + iconVerPadding
        self.aniOffset = aniOffset
        self.aniDegrees = aniDegrees
        self.backgroundColour = backgroundColour
        self.pressAction = pressAction
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: containerWidth, height: containerHeight)
                .foregroundColor(backgroundColour)
                .scaleEffect(showView ? 1 : 0, anchor: .center)
                .animation(.interpolatingSpring(mass: 0.5, stiffness: 100, damping: 10).delay(showView ? 0 : 0.3), value: showView)
            
            HStack(spacing: self.iconHorPadding) {
                
                ForEach(self.icons, id: \.self) { icon in
                    
                    Button(action: {
                        pressAction(icon)
                    }, label: {
                        ReactionIconView(icon: icon,
                                         iconSize: self.iconSize,
                                         aniDegrees: self.aniDegrees,
                                         aniOffset: self.aniOffset,
                                         $showView)
                    })
                }
            }
        }
    }
}

struct ReactionIconView: View {
    
    var icon: String
    var iconSize: CGFloat
    var aniDegrees: Double
    var aniOffset: CGFloat
    
    @Binding var showView: Bool
    
    private var iconImage: UIImage { icon.textToImage(iconSize: iconSize) }
    private let animation: Animation = .interpolatingSpring(mass: 0.5, stiffness: 100, damping: 6)
    
    public init(icon: String,
                iconSize: CGFloat,
                aniDegrees: Double = 0,
                aniOffset: CGFloat = 0,
                _ show: Binding<Bool>) {
        self.icon = icon
        self.iconSize = iconSize
        self.aniDegrees = aniDegrees
        self.aniOffset = aniOffset
        self._showView = show
    }
    
    var body: some View {
        Image(uiImage: iconImage)
            .offset(y: -2.5)
            .frame(width: iconSize,
                   height: iconSize)
            .rotationEffect(.degrees(showView ? 0 : aniDegrees))
            .offset(x: showView ? 0 : aniOffset)
            .scaleEffect(showView ? 1 : 0)
            .animation(showView ? self.animation.delay(showView ? 0.3 : 0) : Animation.linear, value: showView)
    }
}

extension String {
    
    func textToImage(iconSize: CGFloat) -> UIImage {
        let nsString = (self as NSString)
        let font = UIFont.systemFont(ofSize: iconSize)
        let stringAttributes = [NSAttributedString.Key.font: font]
        let imageSize = nsString.size(withAttributes: stringAttributes)

        UIGraphicsBeginImageContextWithOptions(imageSize, false, 0) //  begin image context
        UIColor.clear.set() // clear background
        UIRectFill(CGRect(origin: CGPoint(), size: imageSize)) // set rect size
        nsString.draw(at: CGPoint.zero, withAttributes: stringAttributes) // draw text within rect
        let image = UIGraphicsGetImageFromCurrentImageContext() // create image from context
        UIGraphicsEndImageContext() //  end image context

        return image ?? UIImage()
    }
    
}
