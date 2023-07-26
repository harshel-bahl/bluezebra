//
//  PCError.swift
//  bluezebra
//
//  Created by Harshel Bahl on 09/06/2023.
//

import Foundation

enum PError: Error {
    case failed
    case recordExists
    case noRecordExists
    case multipleRecords
    case typecastError
    case safeMapError
    case fileSystemFailure
    case fileStoreFailure
    case fetchFileFailure
}
