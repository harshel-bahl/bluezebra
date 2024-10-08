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
    
    func jsonDecode(_ inputData: Data) throws -> Any {
        do {
            let decoded = try JSONSerialization.jsonObject(with: inputData)
            
            return decoded as Any
        } catch {
            log.debug(message: "failed to decode data", function: "DataU.jsonDecode", error: error, info: "JSON: \(String(data: inputData, encoding: .utf8) ?? "-")")
            throw DCError.jsonError(err: String(describing: error))
        }
    }
    
    /// jsonDecodeFromData
    /// Decodes a JSON data object into a data packet
    func jsonDecodeFromData<T: Codable>(packet: T.Type,
                                        data: Data) throws -> T {
        do {
            let dataPacket = try JSONDecoder().decode(T.self, from: data)
            return dataPacket
        } catch {
            log.debug(message: "failed to decode data", function: "DataU.jsonDecodeFromData", error: error, info: "JSON: \(String(data: data, encoding: .utf8) ?? "-")")
            throw DCError.jsonError(err: String(describing: error))
        }
    }
    
    /// jsonDecodeFromObject
    /// Decodes a foundation object into a data packet
    func jsonDecodeFromObject<T: Codable>(packet: T.Type,
                                          dataObject: Any) throws -> T {
        do {
            let data = try JSONSerialization.data(withJSONObject: dataObject, options: [])
            let dataPacket = try JSONDecoder().decode(T.self, from: data)
            return dataPacket
        } catch {
            log.debug(message: "failed to decode data", function: "DataU.jsonDecodeFromObject", error: error, info: "JSON: \(dataObject)")
            throw DCError.jsonError(err: String(describing: error))
        }
    }
    
    /// dictionaryToJSONData
    ///
    func dictionaryToJSONData(_ dictionary: [String: Any]) throws -> Data {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            return jsonData
        } catch {
            log.debug(message: "failed to decode data", function: "DataU.dictionaryToJSONData", error: error, info: "JSON: \(dictionary)")
            throw DCError.jsonError(err: String(describing: error))
        }
    }
    
    /// jsonDataToDictionary
    ///
    func jsonDataToDictionary(_ inputData: Data) throws -> [String: Any] {
        do {
            let data = try JSONSerialization.jsonObject(with: inputData, options: [])
            
            guard let dictionary = data as? [String: Any] else { throw DCError.typecastError(err: "couldn't cast data to [String: Any] dictionary") }
            
            return dictionary
        } catch {
            log.debug(message: "failed to decode data", function: "DataU.jsonDataToDictionary", error: error, info: "JSON: \(String(data: inputData, encoding: .utf8) ?? "-")")
            throw DCError.jsonError(err: String(describing: error))
        }
    }
    
    func arrayToJSONData<T>(_ array: [T]) throws -> Data {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: array, options: [])
            return jsonData
        } catch {
            log.debug(message: "failed to decode data", function: "DataU.jsonDecodeFromObject", error: error, info: "JSON: \(array)")
            throw DCError.jsonError(err: String(describing: error))
        }
    }
    
    func jsonDataToArray(_ inputData: Data) throws -> [Any] {
        do {
            if let array = try JSONSerialization.jsonObject(with: inputData, options: .allowFragments) as? [Any] {
                return array
            } else {
                throw DCError.jsonError(err: "Data is not an array")
            }
        } catch {
            log.debug(message: "failed to decode data", function: "DataU.jsonDataToDictionary", error: error, info: "JSON: \(String(data: inputData, encoding: .utf8) ?? "-")")
            throw DCError.jsonError(err: String(describing: error))
        }
    }
    
    func createUniqueID(IDs: [String]) -> String {
        var ID = UUID().uuidString
        
        while !IDs.contains(ID) {
            ID = UUID().uuidString
        }
        
        return ID
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


