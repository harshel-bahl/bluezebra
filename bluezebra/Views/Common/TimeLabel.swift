//
//  TimeLabel.swift
//  bluezebra
//
//  Created by Harshel Bahl on 09/06/2023.
//

import SwiftUI

struct TimeLabel: View {
    
    var date: Date
    var font: Font
    var colour: Color
    var mode: Int
    
    init(date: Date,
         font: Font,
         colour: Color,
         mode: Int) {
        self.date = date
        self.font = font
        self.colour = colour
        self.mode = mode
    }
    
    var body: some View {
        HStack(spacing: 0 ) {
            if mode==1 {
                Text(DateU.shared.timeHm(date: date))
                    .font(font)
                    .foregroundColor(colour)
            } else if mode==2 {
                Text(DateU.shared.timehma(date: date))
                    .font(font)
                    .foregroundColor(colour)
            }
        }
    }
}
