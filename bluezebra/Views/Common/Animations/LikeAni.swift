//
//  LikeAni.swift
//  bluezebra
//
//  Created by Harshel Bahl on 28/06/2023.
//

import SwiftUI

struct LikeAni: View {
    
    @State var isLiked = false
    
    @Binding var likes: Int
    
    var size: CGSize
    var heartColour: Color
    var scale: CGFloat
    var showText: Bool
    var textColour: Color
    var textSize: CGFloat
    var padding: CGFloat
    
    var likeAction: (Bool)->()
    
    init(likes: Binding<Int>,
         size: CGSize = .init(width: 25, height: 25),
         showLikes: Bool,
         heartColour: Color,
scale: CGFloat = 0.8,
         showText: Bool = true,
         textColour: Color = .white,
         textSize: CGFloat = 16,
         padding: CGFloat = 7.5,
         likeAction: @escaping (Bool)->()) {
        self._likes = likes
        self.size = size
        self.heartColour = heartColour
        self.scale = scale
        self.showText = showText
        self.textColour = textColour
        self.textSize = textSize
        self.padding = padding
        self.likeAction = likeAction
    }
    
    var body: some View {
        
        HStack {
            ZStack() {
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(scale)
                    .foregroundColor(heartColour)
                
                Image(systemName: "heart.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .scaleEffect(isLiked ? 1.0 : 0.0)
                    .foregroundColor(heartColour)
                    .animation(.spring(response: isLiked ? 0.5 : 0.2,
                                       dampingFraction: isLiked ? 0.5 : 1), value: isLiked)
            }
            .frame(width: size.width, height: size.height)
            .onTapGesture {
                if !isLiked {
                    incrementLikes()
                }
                
                isLiked.toggle()
            }
            .onChange(of: isLiked) { isLiked in
                self.likeAction(isLiked)
            }
            
            if showText {
                Text(String(likes))
                    .font(.system(size: self.textSize, weight: .light))
                    .foregroundColor(textColour)
                    .animation(Animation.linear(duration: 0.1), value: isLiked)
                    .padding(.leading, self.padding)
            }
        }
    }
    
    func incrementLikes() {
        self.likes += 1
    }
}


