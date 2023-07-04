//
//  TimeLabel.swift
//  bluezebra
//
//  Created by Harshel Bahl on 09/06/2023.
//

import SwiftUI

struct TimeLabel: View {
    
    var date: Date
    var fontSize: CGFloat
    var colour: Color
    var mode: Int
    
    init(date: Date,
         fontSize: CGFloat = 12,
         colour: Color = Color("text1"),
         mode: Int = 1) {
        self.date = date
        self.fontSize = fontSize
        self.colour = colour
        self.mode = mode
    }
    
    var body: some View {
        HStack(spacing: 0 ) {
            if mode==1 {
                FixedText(text: DateU.shared.timeHm(date: date),
                          colour: self.colour,
                          fontSize: self.fontSize)
            } else if mode==2 {
                FixedText(text: DateU.shared.timehma(date: date),
                          colour: self.colour,
                          fontSize: self.fontSize)
            }
        }
    }
}
