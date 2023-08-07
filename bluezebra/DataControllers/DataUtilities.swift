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
    
    /// jsonEncode
    ///
    func jsonEncode(data: Codable) throws -> Data {
        let jsonEncoder = JSONEncoder()
        let data = try jsonEncoder.encode(data)
        return data
    }
    
    /// jsonDecodeFromData
    /// Decodes a JSON data object into a data packet
    func jsonDecodeFromData<T: Codable>(packet: T.Type,
                                        data: Data) throws -> T {
        let dataPacket = try JSONDecoder().decode(T.self, from: data)
        return dataPacket
    }
    
    /// jsonDecodeFromObject
    /// Decodes a foundation object into a data packet
    func jsonDecodeFromObject<T: Codable>(packet: T.Type,
                                          data: Any) throws -> T {
        guard let data = try? JSONSerialization.data(withJSONObject: data, options: []) else { throw DCError.typecastError }
        let dataPacket = try JSONDecoder().decode(T.self, from: data)
        return dataPacket
    }
    
    /// dictionaryToJSONData
    ///
    func dictionaryToJSONData(_ dictionary: [String: Any]) throws -> Data {
        let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        return jsonData
    }
    
    /// jsonDataToDictionary
    ///
    func jsonDataToDictionary(_ jsonData: Data) throws -> [String: Any] {
        let data = try JSONSerialization.jsonObject(with: jsonData, options: [])
        guard let dictionary = data as? [String: Any] else { throw DCError.typecastError }
        return dictionary
    }
    
    /// calcDataSize
    ///
    func calcDataSize(data: Data) -> String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB]
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(data.count))
        return string
    }
}

extension Thread {
    static func printCurrent() {
        print("\r⚡️: \(Thread.current)\r" + "🏭: \(OperationQueue.current?.underlyingQueue?.label ?? "None")\r")
    }
}


