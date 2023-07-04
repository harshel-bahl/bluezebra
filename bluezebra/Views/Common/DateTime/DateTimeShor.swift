//
//  DateTimeShor.swift
//  bluezebra
//
//  Created by Harshel Bahl on 03/07/2023.
//

import SwiftUI

struct DateTimeShor: View {
    
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
        if Calendar.current.isDateInToday(date) {
            FixedText(text: DateU.shared.timeHm(date: date),
                      colour: self.colour,
                      fontSize: self.fontSize)
        } else if Calendar.current.isDateInYesterday(date) {
            FixedText(text: "Yesterday, " + DateU.shared.timeHm(date: date),
                      colour: self.colour,
                      fontSize: self.fontSize)
        } else if date.isInThisWeek {
            FixedText(text: DateU.shared.dateDay(date: date),
                      colour: self.colour,
                      fontSize: self.fontSize)
        } else {
            FixedText(text: DateU.shared.dateDMY(date: date),
                      colour: self.colour,
                      fontSize: self.fontSize)
        }
    }
}

