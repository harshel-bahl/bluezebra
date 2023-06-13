//
//  Avatar.swift
//  bluezebra
//
//  Created by Harshel Bahl on 12/06/2023.
//

import SwiftUI

struct Avatar: View {
    
    let avatar: String
    let size: CGSize
    
    var body: some View {
        avatarButton
    }
    
    var avatarButton: some View {
        if let emoji = BZEmojiProvider1.shared.getEmojiByName(name: avatar) {
            return AnyView(Text(emoji.value)
                .font(.system(size: size.height))
                .frame(width: size.width,
                       height: size.height))
        } else {
            return AnyView(Image(systemName: "person.crop.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size.width,
                       height: size.height)
                    .foregroundColor(Color("blueAccent1")))
        }
    }
}


