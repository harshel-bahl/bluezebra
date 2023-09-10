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
    var logTS: String {
        let d = Date()
        let df = DateFormatter()
        df.timeZone = TimeZone.current
        df.dateFormat = "H:mm:ss:SSSS dd-MM-yy"
        return df.string(from: d)
    }
    
    /// Storage and Networking DateTime Functions
    
    /// currDateTime
    /// current datetime as Date object, given as a time interval relative to UTC reference point (given in UTC timezone)
    var currDT: Date {
        return Date.now
    }
    
    /// currDateTimeUTC
    /// datetime with current timezone as UTC
    var currSDT: String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.timeZone = TimeZone(identifier: "UTC")
        df.locale = Locale(identifier: "en_US_POSIX")
        return df.string(from: self.currDT)
    }
    
    /// dateFromString
    /// current datetime with timezone as UTC
    func dateFromString(_ dateString: String) throws -> Date {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.timeZone = TimeZone(identifier: "UTC")
        df.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = df.date(from: dateString) else { throw DCError.dateFailure(err: "date: \(dateString)")}
        
        return date
    }
    
    /// dateFromStringTZ
    /// current datetime with timezone as UTC
    func dateFromISOString(_ dateString: String) throws -> Date {
        let df = ISO8601DateFormatter()
        df.timeZone = TimeZone(identifier: "UTC")
        
        guard let date = df.date(from: dateString) else { throw DCError.dateFailure(err: "date: \(dateString)")}
        
        return date
    }

    /// stringFromDate
    /// converts date to dateString in the relevant timezone from UTC datetime
    func stringFromDate(_ date: Date,
                        _ timezone: TimeZone = TimeZone(identifier: "UTC")!) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        df.timeZone = timezone
        df.locale = Locale(identifier: "en_US_POSIX")
        return df.string(from: date)
    }
    
    /// UI DateTime Functions
    
    /// dateDMY
    /// returns DMY date in current timezone from UTC timezone date
    func dateDMY(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yy"
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
    
    /// dateDay
    /// returns the day of the week for the given date in UTC timezone
    func dateDay(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "EEEE"
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
        df.dateFormat = "h:ma"
        df.timeZone = TimeZone.current
        df.locale = Locale.current
        return df.string(from: date)
    }
    
    /// datetimeDMYhma
    /// returns (01-01-23, 13:45)
    func datetimeDMYHm(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-yy, HH:mm"
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
    
    /// datetimeDayha
    /// returns (Wednesday, 13:45)
    func datetimeDayHm(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "EEEE, HH:mm"
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
