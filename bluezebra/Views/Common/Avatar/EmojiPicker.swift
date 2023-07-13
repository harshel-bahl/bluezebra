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
    
    let sheetHeight: CGFloat
    let emojiProvider: EmojiProvider
    
    @ViewBuilder var content: () -> Content
    
    init(showEmojiPicker: Binding<Bool>,
         selectedEmoji: Binding<Emoji?>,
         sheetHeight: CGFloat,
         emojiProvider: EmojiProvider,
         content: @escaping () -> Content) {
        self._showEmojiPicker = showEmojiPicker
        self._selectedEmoji = selectedEmoji
        self.sheetHeight = sheetHeight
        self.emojiProvider = emojiProvider
        self.content = content
    }
    
    var body: some View {
        content()
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

