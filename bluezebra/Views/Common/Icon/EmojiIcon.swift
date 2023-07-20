//
//  EmojiIcon.swift
//  bluezebra
//
//  Created by Harshel Bahl on 12/06/2023.
//

import SwiftUI
import EmojiPicker

struct EmojiIcon: View {
    
    let avatar: String
    let size: CGSize
    
    let emojis: [Emoji]
    
    let buttonAction: ((String)->())?
    
    init(avatar: String,
         size: CGSize,
         emojis: [Emoji],
         buttonAction: @escaping (String) -> ()) {
        self.avatar = avatar
        self.size = size
        self.emojis = emojis
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        if let _ = buttonAction {
            iconButton
        } else {
            icon
        }
    }
    
    @ViewBuilder
    var icon: some View {
        if let emoji = self.getEmoji(name: self.avatar,
                                     emojis: self.emojis) {
            Text(emoji.value)
                .font(.system(size: size.height))
                .frame(width: size.width,
                       height: size.height)
        }
    }
    
    @ViewBuilder
    var iconButton: some View {
        if let emoji = self.getEmoji(name: self.avatar,
                                     emojis: self.emojis),
           let buttonAction = self.buttonAction {
            Button(action: {
                buttonAction(self.avatar)
            }, label: {
                Text(emoji.value)
                    .font(.system(size: size.height))
                    .frame(width: size.width,
                           height: size.height)
            })
        }
    }
    
    func getEmoji(name: String,
                  emojis: [Emoji]) -> Emoji? {
        
        var outputEmojis = [Emoji]()
        
        for emoji in emojis {
            if emoji.name == name {
                outputEmojis.append(emoji)
            }
        }
        
        return outputEmojis.first
    }
}


