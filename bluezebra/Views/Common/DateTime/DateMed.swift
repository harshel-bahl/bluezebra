//
//  DateMed.swift
//  bluezebra
//
//  Created by Harshel Bahl on 09/06/2023.
//

import SwiftUI

struct DateMed: View {
    
    var date: Date
    var fontSize: CGFloat
    var colour: Color
    
    init(date: Date,
         fontSize: CGFloat,
         colour: Color) {
        self.date = date
        self.fontSize = fontSize
        self.colour = colour
    }
    
    var body: some View {
        HStack(spacing: 0 ) {
            if Calendar.current.isDateInToday(date) {
                Text("Today")
                    .font(.system(size: self.fontSize))
                    .foregroundColor(self.colour)
            } else if Calendar.current.isDateInYesterday(date) {
                Text("Yesterday")
                    .font(.system(size: self.fontSize))
                    .foregroundColor(self.colour)
            } else if date.isInThisWeek {
                FixedText(text: DateU.shared.dateDay(date: date),
                          colour: self.colour,
                          fontSize: self.fontSize)
            } else {
                FixedText(text: DateU.shared.dateMed(date: date),
                          colour: self.colour,
                          fontSize: self.fontSize)
            }
        }
    }
}
