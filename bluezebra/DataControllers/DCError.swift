//
//  DCError.swift
//  bluezebra
//
//  Created by Harshel Bahl on 27/05/2023.
//

import Foundation

enum DCError: Error {
    case failed
    case serverError(message: String)
    case timeOut
    case disconnected
    case typecastError
    case nilError
    case jsonError
    case imageDataFailure
    case remoteDataNil
    case multipleRemoteDataInstances
    case invalidRequest
}
