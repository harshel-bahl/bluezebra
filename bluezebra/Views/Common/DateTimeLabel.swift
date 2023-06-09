//
//  DateTimeLabel.swift
//  bluezebra
//
//  Created by Harshel Bahl on 06/06/2023.
//

import SwiftUI

struct DateTimeLabel: View {
    
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
                if Calendar.current.isDateInToday(date) {
                    Text("Today,")
                        .font(font)
                        .foregroundColor(colour)
                    
                    Text(DateU.shared.timehma(date: date))
                        .font(font)
                        .foregroundColor(colour)
                        .padding(.leading, 10)
                } else if Calendar.current.isDateInYesterday(date) {
                    Text("Yesterday,")
                        .font(font)
                        .foregroundColor(colour)
                    
                    Text(DateU.shared.timehma(date: date))
                        .font(font)
                        .foregroundColor(colour)
                        .padding(.leading, 10)
                } else if date.isInThisWeek {
                    Text(DateU.shared.datetimeDayha(date: date))
                        .font(font)
                        .foregroundColor(colour)
                } else {
                    if mode==1 {
                        Text(DateU.shared.datetimeDMYhma(date: date))
                            .font(font)
                            .foregroundColor(colour)
                    } else if mode==2 {
                        Text(DateU.shared.dateDMY(date: date))
                            .font(font)
                            .foregroundColor(colour)
                    }
                }
        }
    }
}


