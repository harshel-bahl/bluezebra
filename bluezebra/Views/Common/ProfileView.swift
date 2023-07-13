//
//  ProfileView.swift
//  bluezebra
//
//  Created by Harshel Bahl on 28/06/2023.
//

import SwiftUI
import EmojiPicker

struct ProfileView<Content: View>: View {
    
    let avatar: String
    let iconSize: CGSize
    let emojis: [Emoji]
    
    let name: String
    let nameColour: Color
    let fontSize: CGFloat
    
    let content: () -> Content
    
    init(avatar: String,
         iconSize: CGSize,
         emojis: [Emoji],
         name: String,
         nameColour: Color,
         fontSize: CGFloat,
         content: @escaping () -> Content) {
        self.avatar = avatar
        self.iconSize = iconSize
        self.emojis = emojis
        self.name = name
        self.nameColour = nameColour
        self.fontSize = fontSize
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0) {
            EmojiIcon(avatar: avatar,
                      size: iconSize,
                      emojis: emojis, buttonAction: { avatar in
                
            })
            .padding(.bottom, 20)
            
            FixedText(text: name,
                      colour: nameColour,
                      fontSize: fontSize)
            
            content()
        }
    }
}

