//
//  DataUtilities.swift
//  bluezebra
//
//  Created by Harshel Bahl on 27/05/2023.
//

import Foundation

class DU {
    
    static let shared = DU()
    
    var date: Date {
        return Date.now
    }
    
    func currTime() -> String {
        let d = Date()
        let df = DateFormatter()
        df.dateFormat = "y-MM-dd H:mm:ss.SSSS"

        return df.string(from: d)
    }
    
    func extractedTime(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "H:mm"
        return df.string(from: date)
    }
    
    func extractedDate(date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "y-MM-dd"
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
