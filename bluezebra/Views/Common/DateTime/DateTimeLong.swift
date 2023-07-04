//
//  DateTimeLong.swift
//  bluezebra
//
//  Created by Harshel Bahl on 03/07/2023.
//

import SwiftUI

struct DateTimeLong: View {
    
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
            FixedText(text: "Today, " + DateU.shared.timeHm(date: date),
                      colour: self.colour,
                      fontSize: self.fontSize)
        } else if Calendar.current.isDateInYesterday(date) {
            FixedText(text: "Yesterday, " + DateU.shared.timeHm(date: date),
                      colour: self.colour,
                      fontSize: self.fontSize)
        } else if date.isInThisWeek {
            FixedText(text: DateU.shared.datetimeDayHm(date: date),
                      colour: self.colour,
                      fontSize: self.fontSize)
        } else {
            FixedText(text: DateU.shared.datetimeMedShor(date: date),
                      colour: self.colour,
                      fontSize: self.fontSize)
        }
    }
    
}

