//
//  TabView1.swift
//  bluezebra
//
//  Created by Harshel Bahl on 27/06/2023.
//

import SwiftUI

struct TabView1: View {
    
    @EnvironmentObject var SP: ScreenProperties
    
    @Binding var tab: String
    
    let tabNames: [String]
    let imageNames: [String]
    let selectedNames: [String]
    let iconSize: CGSize
    let iconPadding: CGFloat
    let fontSize: CGFloat
    let selectedColour: Color
    let unselectedColour: Color
    let backgroundColour: Color
    let betweenPadding: CGFloat
    let edgeInsets: EdgeInsets
    
    init(tab: Binding<String>,
         tabNames: [String],
         imageNames: [String],
         selectedNames: [String],
         iconSize: CGSize = .init(width: 27.5, height: 27.5),
         iconPadding: CGFloat = 7.5,
         fontSize: CGFloat = 10,
         selectedColour: Color,
         unselectedColour: Color,
         backgroundColour: Color,
         betweenPadding: CGFloat,
         edgeInsets: EdgeInsets = .init(top: 5, leading: 0, bottom: 5, trailing: 0)) {
        self._tab = tab
        self.tabNames = tabNames
        self.imageNames = imageNames
        self.selectedNames = selectedNames
        self.iconSize = iconSize
        self.iconPadding = iconPadding
        self.fontSize = fontSize
        self.selectedColour = selectedColour
        self.unselectedColour = unselectedColour
        self.backgroundColour = backgroundColour
        self.betweenPadding = betweenPadding
        self.edgeInsets = edgeInsets
    }
    
    var body: some View {
        HStack(spacing: 0) {
            
            Spacer()
            
            ForEach(tabNames.indices, id: \.self) { index in
                Button(action: {
                    self.tab = self.tabNames[index]
                }, label: {
                    VStack(spacing: 0) {
                        Image(systemName: self.tab == self.tabNames[index] ? self.selectedNames[index] : self.imageNames[index])
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(self.tab == self.tabNames[index] ? selectedColour : unselectedColour)
                            .frame(width: iconSize.width, height: iconSize.height)
                        
                        FixedText(text: self.tabNames[index],
                                  colour: self.tab == self.tabNames[index] ? selectedColour : unselectedColour,
                                  fontSize: fontSize)
                        .padding(.top, iconPadding)
                    }
                })
                .if(index != 0, transform: { view in
                    view
                        .padding(.leading, betweenPadding/2)
                })
                .if(index != tabNames.indices.last, transform: { view in
                    view
                        .padding(.trailing, betweenPadding/2)
                })
            }
            
            Spacer()
        }
        .padding(.top, edgeInsets.top)
        .padding(.bottom, edgeInsets.bottom)
        .background() { backgroundColour }
    }
}


