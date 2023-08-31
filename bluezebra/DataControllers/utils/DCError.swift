//
//  DCError.swift
//  bluezebra
//
//  Created by Harshel Bahl on 27/05/2023.
//

import Foundation

enum DCError: Error {
    
    /// Server Failures
    case serverFailure(err: String = "")
    case serverTimeOut(err: String = "")
    case socketDisconnected(err: String = "")
    case userDisconnected(err: String = "")
    case receivedPendingEventsFailure(err: String = "")
    case remoteDataNil(err: String = "")
    case multipleRemoteInstances(err: String = "")
    
    /// Client Failures
    case clientFailure(err: String = "")
    case typecastError(err: String = "")
    case nilError(err: String = "")
    case jsonError(err: String = "")
    case invalidRequest(err: String = "")
    case imageDataFailure(err: String = "")
    case dateFailure(err: String = "")
    case authFailure(err: String = "")
    case fileSystemFailure(err: String = "")
    case securityFailure(err: String = "")
    
    
    static func stackTrace() -> String? {
        #if DEBUG
        let stack = Thread.callStackSymbols
        let stackS = stack.joined(separator: "\n")
        return stackS
        #else
        return nil
        #endif
    }
}
