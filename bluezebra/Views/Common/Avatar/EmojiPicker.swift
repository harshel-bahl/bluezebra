//
//  EmojiPicker.swift
//  bluezebra
//
//  Created by Harshel Bahl on 26/06/2023.
//

import SwiftUI
import EmojiPicker

struct EmojiPicker<Content: View>: View {
    
    @Binding var showEmojiPicker: Bool
    @Binding var selectedEmoji: Emoji?
    
    @ViewBuilder var content: (Binding<Bool>, Binding<Emoji?>) -> Content
    
    let sheetHeight: CGFloat
    let emojiProvider: EmojiProvider
    
    init(showEmojiPicker: Binding<Bool>,
         selectedEmoji: Binding<Emoji?>,
         content: @escaping (Binding<Bool>, Binding<Emoji?>) -> Content,
         sheetHeight: CGFloat,
         emojiProvider: EmojiProvider) {
        self._showEmojiPicker = showEmojiPicker
        self._selectedEmoji = selectedEmoji
        self.content = content
        self.sheetHeight = sheetHeight
        self.emojiProvider = emojiProvider
    }
    
    var body: some View {
        content($showEmojiPicker, $selectedEmoji)
            .sheet(isPresented: $showEmojiPicker) {
                emojiPickerView
                    .presentationDetents([.height(sheetHeight)])
            }
    }
    
    var emojiPickerView: some View {
        EmojiPickerView(selectedEmoji: $selectedEmoji,
                        selectedColor: .blue,
                        emojiProvider: self.emojiProvider)
        .padding()
    }
}

