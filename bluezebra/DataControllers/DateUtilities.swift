//
//  DateUtilities.swift
//  bluezebra
//
//  Created by Harshel Bahl on 08/06/2023.
//

import Foundation

class DateU {
    
    static let shared = DateU()
    
    /// logTS
    /// log timestamp for debugging
    func logTS() -> String {
        let d = Date()
        let df = DateFormatter()
        df.timeZone = TimeZone.current
        df.dateFormat = "H:mm:ss:SSSS dd-MM-yy"
        return df.string(from: d)
    }
    
    /// currDateTime
    /// current datetime as Date object, given as a time interval relative to UTC reference point (given in UTC timezone)
    var currDT: Date {
        return Date.now
    }
    
    /// currDateTimeUTC
    /// datetime with current timezone offset from UTC
    var currSDateTime: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        df.timeZone = TimeZone.current
        return df.string(from: self.currDT)
    }
    
    /// dateFromString
    /// current datetime in UTC converted from the relevant timezone offset
    func dateFromString(dateString: String) -> Date? {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        return df.date(from: dateString)
    }
    
    /// stringFromDate
    /// converts date to dateString in relevant timezone offset from UTC
    func stringFromDate(date: Date,
                        timezone: TimeZone) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        df.timeZone = timezone
        return df.string(from: date)
    }
    
    /// dateDMY
    /// returns DMY date in current timezone from UTC timezone date
    func dateDMY(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "d-M-yy"
        df.timeZone = TimeZone.current
        df.locale = Locale.current
        return df.string(from: date)
    }
    
    /// datetimeDMYhma
    /// returns (01-01-23, 11:45 PM)
    func datetimeDMYhma(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yy, h:mma"
        df.timeZone = TimeZone.current
        df.locale = Locale.current
        return df.string(from: date)
    }
    
    /// dateMed
    /// returns medium style date (Jun 9, 2023) with UTC timezone
    func dateMed(date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeZone = TimeZone.current
        df.locale = Locale.current
        return df.string(from: date)
    }
    
    /// datetimeMedShor
    /// returns (Jun 9, 2023 at 3:30 PM) with UTC timezone
    func datetimeMedShor(date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        df.timeZone = TimeZone.current
        df.locale = Locale.current
        return df.string(from: date)
    }
    
    /// dateDay
    /// returns the day of the week for the given date in UTC timezone
    func dateDay(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "EEEE"
        df.timeZone = TimeZone.current
        df.locale = Locale.current
        return df.string(from: date)
    }
    
    /// datetimeDayha
    /// returns (Wednesday, 1:13PM)
    func datetimeDayha(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "EEEE, h:mma"
        df.timeZone = TimeZone.current
        df.locale = Locale.current
        return df.string(from: date)
    }
    
    /// timeHm
    /// returns the timestamp as 24 hour clock
    func timeHm(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        df.timeZone = TimeZone.current
        df.locale = Locale.current
        return df.string(from: date)
    }
    
    /// timehma
    /// returns the timestamp as 12 hour clock with AM/PM
    func timehma(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "h:mma"
        df.timeZone = TimeZone.current
        df.locale = Locale.current
        return df.string(from: date)
    }

}

extension Date {

    func isEqual(to date: Date, toGranularity component: Calendar.Component, in calendar: Calendar = .current) -> Bool {
        calendar.isDate(self, equalTo: date, toGranularity: component)
    }

    func isInSameYear(as date: Date) -> Bool { isEqual(to: date, toGranularity: .year) }
    func isInSameMonth(as date: Date) -> Bool { isEqual(to: date, toGranularity: .month) }
    func isInSameWeek(as date: Date) -> Bool { isEqual(to: date, toGranularity: .weekOfYear) }

    func isInSameDay(as date: Date) -> Bool { Calendar.current.isDate(self, inSameDayAs: date) }

    var isInThisYear:  Bool { isInSameYear(as: Date()) }
    var isInThisMonth: Bool { isInSameMonth(as: Date()) }
    var isInThisWeek:  Bool { isInSameWeek(as: Date()) }

    var isInYesterday: Bool { Calendar.current.isDateInYesterday(self) }
    var isInToday:     Bool { Calendar.current.isDateInToday(self) }
    var isInTomorrow:  Bool { Calendar.current.isDateInTomorrow(self) }

    var isInTheFuture: Bool { self > Date() }
    var isInThePast:   Bool { self < Date() }
}
