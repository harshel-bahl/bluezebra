//
//  DataUtilities.swift
//  bluezebra
//
//  Created by Harshel Bahl on 27/05/2023.
//

import Foundation

class DataU {
    
    static let shared = DataU()
    

    var date: Date {
        return Date.now
    }

    func currTime() -> String {
        let d = Date()
        let df = DateFormatter()
        df.dateFormat = "H:mm:ss.SSSS dd-MM"

        return df.string(from: d)
    }

    func timeHM(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "H:mm"
        df.locale = Locale.current
        return df.string(from: date)
    }

    func dateDMY(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd-MM-y"
        return df.string(from: date)
    }

    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd- HH:mm:ss"
        return dateFormatter.string(from: Date.now)
    }

    let stringFromDate = { (date: Date) -> String? in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd- HH:mm:ss"
        return dateFormatter.string(from: date)
    }

    let dateFromString =  { (dateString: String) -> Date? in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd- HH:mm:ss"
        return dateFormatter.date(from: dateString)
    }

    func localToUTC(dateStr: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        dateFormatter.calendar = Calendar.current
        dateFormatter.timeZone = TimeZone.current

        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            dateFormatter.dateFormat = "H:mm:ss"

            return dateFormatter.string(from: date)
        }
        return nil
    }

    func utcToLocal(dateStr: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "H:mm:ss"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

        if let date = dateFormatter.date(from: dateStr) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "h:mm a"

            return dateFormatter.string(from: date)
        }
        return nil
    }

    
    
    
    
    let jsonEncode = { (data: Codable) throws -> Data in
        let jsonEncoder = JSONEncoder()
        let data = try jsonEncoder.encode(data)
        return data
       
    }
    
    let jsonDecode = { (data: Codable) throws -> Data in
        let jsonEncoder = JSONEncoder()
        let data = try jsonEncoder.encode(data)
        return data
    }
    
    func jsonDecodeFromObject<T: Codable>(packet: T.Type,
                                          data: Any) throws -> T {
        guard let data = try? JSONSerialization.data(withJSONObject: data as Any, options: []) else { throw DCError.typecastError }
        let dataPacket = try JSONDecoder().decode(T.self, from: data)
        return dataPacket
    }
    
    func jsonDecodeFromData<T: Codable>(packet: T.Type,
                                        data: Any) throws -> T {
        
        guard let data = data as? Data else { throw DCError.typecastError }
        let dataPacket = try JSONDecoder().decode(T.self, from: data)
        return dataPacket
    }
}

extension Thread {
    class func printCurrent() {
        print("\r⚡️: \(Thread.current)\r" + "🏭: \(OperationQueue.current?.underlyingQueue?.label ?? "None")\r")
    }
}

