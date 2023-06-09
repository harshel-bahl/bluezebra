//
//  BZEmojiProvider1.swift
//  bluezebra
//
//  Created by Harshel Bahl on 23/05/2023.
//

import SwiftUI
import EmojiPicker

final class BZEmojiProvider1: EmojiProvider {
    
    static let shared = BZEmojiProvider1()
    
    func getAll() -> [Emoji] {
        return [
            Emoji(value: "🐵", name: "monkey_face"),
            Emoji(value: "🐶", name: "dog"),
            Emoji(value: "🦊", name: "fox_face"),
            Emoji(value: "🐱", name: "cat"),
            Emoji(value: "🦁", name: "lion"),
            Emoji(value: "🐯", name: "tiger"),
            Emoji(value: "🐮", name: "cow"),
            Emoji(value: "🐷", name: "pig"),
            Emoji(value: "🐭", name: "mouse"),
            Emoji(value: "🐹", name: "hamster"),
            Emoji(value: "🐰", name: "rabbit"),
            Emoji(value: "🐻", name: "bear"),
            Emoji(value: "🐻‍❄️", name: "polar_bear"),
            Emoji(value: "🐨", name: "koala"),
            Emoji(value: "🐼", name: "panda_face"),
            Emoji(value: "🐸", name: "frog"),
            Emoji(value: "🐲", name: "dragon_face"),
            Emoji(value: "🐙", name: "octopus"),
            Emoji(value: "🦉", name: "owl"),
            Emoji(value: "🐒", name: "monkey"),
            Emoji(value: "🦋", name: "butterfly"),
            Emoji(value: "🦈", name: "shark"),
            Emoji(value: "🐬", name: "dolphin"),
            Emoji(value: "🐳", name: "whale"),
            Emoji(value: "🦚", name: "peacock"),
            Emoji(value: "🐝", name: "bee"),
            Emoji(value: "🐺", name: "wolf"),
            Emoji(value: "🦍", name: "gorilla"),
            Emoji(value: "🦇", name: "bat"),
            Emoji(value: "🐿️", name: "chipmunk"),
            Emoji(value: "🦥", name: "sloth"),
            Emoji(value: "🦄", name: "unicorn"),
            Emoji(value: "🐔", name: "chicken"),
        ]
    }
    
    func getEmojiByName(name: String) -> Emoji? {
            
            var outputEmojis = [Emoji]()
            
            for emoji in self.getAll() {
                if emoji.name == name {
                    outputEmojis.append(emoji)
                }
            }
            
        return outputEmojis.first
    }
}

