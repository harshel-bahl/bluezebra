//
//  DCError.swift
//  bluezebra
//
//  Created by Harshel Bahl on 27/05/2023.
//

import Foundation

enum DCError: Error {
    
    /// Server Failures
    case socketFailure(func: String, err: String = "")
    case serverFailure(func: String, err: String = "")
    case serverTimeOut(func: String)
    case serverDisconnected(func: String)
    case userDisconnected(func: String)
    case remoteDataNil(func: String, err: String = "")
    case multipleRemoteDataInstances(func: String, err: String = "")
    
    /// Client Failures
    case clientFailure(func: String, err: String = "")
    case typecastError(func: String, err: String = "")
    case nilError(func: String, err: String = "")
    case jsonError(func: String, err: String = "")
    case invalidRequest(func: String, err: String = "")
    case imageDataFailure(func: String, err: String = "")
    case dateFailure(func: String, err: String = "")
    case authFailure(func: String, err: String = "")
    case fileSystemFailure(func: String, err: String = "")
}
