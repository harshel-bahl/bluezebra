//
//  DateLabel.swift
//  bluezebra
//
//  Created by Harshel Bahl on 09/06/2023.
//

import SwiftUI

struct DateLabel: View {
    
    var date: Date
    var font: Font
    var colour: Color
    
    init(date: Date,
         font: Font,
         colour: Color) {
        self.date = date
        self.font = font
        self.colour = colour
    }
    
    var body: some View {
        HStack(spacing: 0 ) {
            if Calendar.current.isDateInToday(date) {
                Text("Today")
                    .font(font)
                    .foregroundColor(colour)
            } else if Calendar.current.isDateInYesterday(date) {
                Text("Yesterday")
                    .font(font)
                    .foregroundColor(colour)
            } else if date.isInThisWeek {
                Text(DateU.shared.dateDay(date: date))
                    .font(font)
                    .foregroundColor(colour)
            } else {
                Text(DateU.shared.dateMed(date: date))
                    .font(font)
                    .foregroundColor(colour)
            }
        }
    }
}
