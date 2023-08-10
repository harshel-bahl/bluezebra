//
//  PCError.swift
//  bluezebra
//
//  Created by Harshel Bahl on 09/06/2023.
//

import Foundation

enum PError: Error {
    case persistenceError(func: String, err: String = "")
    case recordExists(func: String, err: String = "")
    case noRecordExists(func: String, err: String = "")
    case multipleRecords(func: String, err: String = "")
    case typecastError(func: String, err: String = "")
    case safeMapError(func: String, err: String = "")
    case fileSystemFailure(func: String, err: String = "")
    case imageDataFailure(func: String, err: String = "")
}
