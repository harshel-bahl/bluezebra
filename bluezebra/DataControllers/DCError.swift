//
//  DCError.swift
//  bluezebra
//
//  Created by Harshel Bahl on 27/05/2023.
//

import Foundation

enum DCError: Error {
    case failed
    case timeOut
    case serverFailure
    case disconnected
    case typecastError
    case jsonError
}
