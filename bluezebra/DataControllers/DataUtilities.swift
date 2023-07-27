//
//  DataUtilities.swift
//  bluezebra
//
//  Created by Harshel Bahl on 27/05/2023.
//

import Foundation
import ImageIO
import SwiftUI

class DataU {
    
    static let shared = DataU()
    
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
    
    func calcDataSize(data: Data) -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB]
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(data.count))
        return string
    }
}

extension Thread {
    class func printCurrent() {
        print("\r⚡️: \(Thread.current)\r" + "🏭: \(OperationQueue.current?.underlyingQueue?.label ?? "None")\r")
    }
}


