//
//  EmojiGrid.swift
//  bluezebra
//
//  Created by Harshel Bahl on 03/08/2023.
//

import SwiftUI
import EmojiPicker

struct EmojiGrid: View {
    
    let emojis: [Emoji]
    let emojiSize: CGSize
    let indexView: Bool
    let paddingOnIndexView: CGFloat
    let gridSize: CGSize?
    let gridPadding: EdgeInsets
    let selectedPadding: CGFloat
    let selectedCR: CGFloat
    let selectedColour: Color
    let selectedLineWidth: CGFloat
    
    @Binding var selectedEmoji: Emoji?
    
    init(emojis: [Emoji],
         emojiSize: CGSize = .init(width: 57.5, height: 57.5),
         indexView: Bool = true,
         paddingOnIndexView: CGFloat = 55,
         gridSize: CGSize? = nil,
         gridPadding: EdgeInsets = .init(top: 5, leading: 25, bottom: 5, trailing: 25),
         selectedPadding: CGFloat = 10,
         selectedCR: CGFloat = 17.5,
         selectedColour: Color = Color("accent1"),
         selectedLineWidth: CGFloat = 3,
         selectedEmoji: Binding<Emoji?>) {
        self.emojis = emojis
        self.emojiSize = emojiSize
        self.indexView = indexView
        self.paddingOnIndexView = paddingOnIndexView
        self.gridSize = gridSize
        self.gridPadding = gridPadding
        self.selectedPadding = selectedPadding
        self.selectedCR = selectedCR
        self.selectedColour = selectedColour
        self.selectedLineWidth = selectedLineWidth
        self._selectedEmoji = selectedEmoji
    }
    
    var body: some View {
        TabView {
            
            let pages = constructArray()
            ForEach(pages, id: \.self) { columnRows in
           
                VStack(spacing: 0) {
                    ForEach(columnRows.indices, id: \.self) { rowIndex in
                        
                        if rowIndex != 0 {
                            Spacer()
                        }
                        
                        let row = columnRows[rowIndex]
                        HStack(spacing: 0) {
                            ForEach(row.indices, id: \.self) { emojiIndex in
                                
                                if emojiIndex != 0 {
                                    Spacer()
                                }
                                
                                Button(action: {
                                    withAnimation {
                                        self.selectedEmoji = row[emojiIndex]
                                    }
                                }, label: {
                                    Text(row[emojiIndex].value)
                                        .font(.system(size: emojiSize.height))
                                        .frame(width: emojiSize.width,
                                               height: emojiSize.height)
                                        .padding(selectedPadding)
                                        .overlay {
                                            if selectedEmoji?.name == row[emojiIndex].name {
                                                RoundedRectangle(cornerRadius: selectedCR)
                                                    .stroke(selectedColour, lineWidth: selectedLineWidth)
                                            }
                                        }
                                })
                                
                                if emojiIndex != 3 {
                                    Spacer()
                                }
                            }
                        }
                        
                        if rowIndex != 3 {
                            Spacer()
                        }
                    }
                }
            }
            .padding(gridPadding)
            .if(indexView == true, transform: { view in
                view
                    .padding(.bottom, paddingOnIndexView)
            })
        }
        .tabViewStyle(.page)
        .if(indexView == true, transform: { view in
            view
                .indexViewStyle(.page(backgroundDisplayMode: .always))
        })
        .frame(width: gridSize?.width,
               height: gridSize?.height)
    }
    
    func constructArray() -> [[[Emoji]]] {
        var pages = [[[Emoji]]]()
        var columnRows = [[Emoji]]()
        var row = [Emoji]()
        
        var emojiIndex = 0
        var columnRowCount = 0
        var rowCount = 0
        
        while emojiIndex < emojis.count {
            if rowCount < 4 && columnRowCount < 4 {
                row.append(emojis[emojiIndex])
                rowCount += 1
                emojiIndex += 1
            } else if columnRowCount < 4 {
                columnRows.append(row)
                columnRowCount += 1
                rowCount = 0
                row = [Emoji]()
            } else {
                pages.append(columnRows)
                columnRows = [[Emoji]]()
                columnRowCount = 0
                row = [Emoji]()
                rowCount = 0
            }
        }
        
        if rowCount > 0 || columnRowCount > 0 {
            if rowCount < 4 {
                columnRows.append(row)
                pages.append(columnRows)
            } else {
                pages.append(columnRows)
            }
        }
       
        return pages
    }
}

