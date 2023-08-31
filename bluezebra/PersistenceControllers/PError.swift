//
//  PCError.swift
//  bluezebra
//
//  Created by Harshel Bahl on 09/06/2023.
//

import Foundation

enum PError: Error {
    case persistenceError(err: String = "")
    case recordExists(err: String = "")
    case noRecordExists(err: String = "")
    case multipleRecords(err: String = "")
    case typecastError(err: String = "")
    case safeMapError(err: String = "")
    case invalidRequest(err: String = "")
    case fileSystemFailure(err: String = "")
    case imageDataFailure(err: String = "")
    case securityFailure(err: String = "")
}
