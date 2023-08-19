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
        do {
            let dataPacket = try JSONDecoder().decode(T.self, from: data)
            return dataPacket
        } catch {
            throw DCError.jsonError(func: "jsonDecodeFromData", err: error.localizedDescription)
        }
    }
    
    /// jsonDecodeFromObject
    /// Decodes a foundation object into a data packet
    func jsonDecodeFromObject<T: Codable>(packet: T.Type,
                                          data: Any) throws -> T {
        do {
            let data = try JSONSerialization.data(withJSONObject: data, options: [])
            let dataPacket = try JSONDecoder().decode(T.self, from: data)
            return dataPacket
        } catch {
            throw DCError.jsonError(func: "jsonDecodeFromObject", err: error.localizedDescription)
        }
    }
    
    /// dictionaryToJSONData
    ///
    func dictionaryToJSONData(_ dictionary: [String: Any]) throws -> Data {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            return jsonData
        } catch {
            throw DCError.jsonError(func: "dictionaryToJSONData", err: error.localizedDescription)
        }
    }
    
    /// jsonDataToDictionary
    ///
    func jsonDataToDictionary(_ jsonData: Data) throws -> [String: Any] {
        do {
            let data = try JSONSerialization.jsonObject(with: jsonData, options: [])
            
            guard let dictionary = data as? [String: Any] else { throw DCError.typecastError(func: "jsonDataToDictionary", err: "couldn't cast data to [String: Any] dictionary") }
            
            return dictionary
        } catch {
            if let error = error as? DCError {
                throw error
            } else {
                throw DCError.jsonError(func: "jsonDataToDictionary", err: error.localizedDescription)
            }
        }
    }
    
    func arrayToJSONData<T>(_ array: [T]) throws -> Data {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: array, options: [])
            return jsonData
        } catch {
            throw DCError.jsonError(func: "arrayToJSONData", err: error.localizedDescription)
        }
    }
    
    func jsonDataToArray(_ jsonData: Data) throws -> [Any] {
        do {
            if let array = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [Any] {
                return array
            } else {
                throw DCError.jsonError(func: "jsonDataToArray", err: "Data is not an array")
            }
        } catch {
            throw DCError.jsonError(func: "jsonDataToArray", err: error.localizedDescription)
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
    
    func handleSuccess(function: String,
                       DT: String = DateU.shared.logTS,
                       info: String? = nil) {
        if let info = info {
            print("SUCCESS \(DT) -- function: \(function), info: (\(info))")
        } else {
            print("SUCCESS \(DT) -- function: \(function)")
        }
    }
    
    func handleSuccess(info: String,
                       DT: String = DateU.shared.logTS) {
        print("SUCCESS \(DT) -- info: (\(info))")
    }
    
    func handleFailure(function: String,
                       DT: String = DateU.shared.logTS,
                       err: Error,
                       info: String? = nil) {
        if let info = info {
            print("FAILED \(DT) -- function: \(function), error: \(err), info: (\(info))")
        } else {
            print("FAILED \(DT) -- function: \(function), error: \(err)")
        }
    }
    
    func handleFailure(info: String,
                       DT: String = DateU.shared.logTS) {
        print("FAILED \(DT) -- info: (\(info))")
    }
    
    func handleEventTrigger(eventName: String,
                            DT: String = DateU.shared.logTS) {
        print("SUCCESS \(DT) -- event triggered: \(eventName)")
    }
    
    func handleEventSuccess(eventName: String,
                            DT: String = DateU.shared.logTS) {
        print("SUCCESS \(DT) -- event: \(eventName)")
    }
    
    func handleEventFailure(eventName: String,
                            DT: String = DateU.shared.logTS,
                            err: Error) {
        print("SUCCESS \(DT) -- event: \(eventName), error: \(err)")
    }
}

extension Thread {
    static func printCurrent() {
        print("\r⚡️: \(Thread.current)\r" + "🏭: \(OperationQueue.current?.underlyingQueue?.label ?? "None")\r")
    }
}


