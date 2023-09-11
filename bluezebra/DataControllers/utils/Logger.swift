//
//  Logger.swift
//  bluezebra
//
//  Created by Harshel Bahl on 29/08/2023.
//

import Foundation
import SwiftyBeaver


let log = Logger.shared

class Logger {
    
    static let shared = Logger()
    
    let log: SwiftyBeaver.Type
    
    /// Log Levels
    /// - Verbose
    /// - Debug
    /// - Info
    /// - Warning
    /// - Error
    /// - Severe
    
    init() {
        
        self.log = SwiftyBeaver.self
        
        var minLevel: SwiftyBeaver.Level = .info
        
#if DEBUG
        minLevel = .debug
#endif
        
#if DEBUG
        let console = ConsoleDestination()
        console.format = "$DHH:mm:ss.SSS$d $C$L$c: $M"
        console.minLevel = minLevel
        log.addDestination(console)
#endif
        
        let file = FileDestination()
        file.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $L: $M"
        file.minLevel = minLevel
        log.addDestination(file)
    }
    
    func createLogObj(
        message: String? = nil,
        function: String? = nil,
        event: String? = nil,
        error: Error? = nil,
        info: String? = nil,
        UID: String? = nil,
        recUID: String? = nil
    ) -> String {
        
        var baseS = ""
        
        if let message = message {
            baseS += "\(message)"
        }
        
        if let function = function {
            baseS += baseS == "" ? "func: \(function)" : " | func: \(function)"
        }
        
        if let event = event {
            baseS += baseS == "" ? "event: \(event)" : " | event: \(event)"
        }
        
        if let error = error {
            baseS += baseS == "" ? "err: \(error)" : " | err: \(error)"
        }
        
        if let info = info {
            baseS += baseS == "" ? "info: (\(info))" : " | info: (\(info))"
        }
        
        if let UID = UID {
            baseS += baseS == "" ? "UID: \(UID)" : " | UID: \(UID)"
        } else if let UID = UserDC.shared.userdata?.uID {
            baseS += baseS == "" ? "UID: \(UID)" : " | UID: \(UID)"
        }
        
        if let recUID = recUID {
            baseS += baseS == "" ? "recUID: \(recUID)" : " | recUID: \(recUID)"
        }
        
        return baseS
    }
    
    func debug(
        message: String? = nil,
        function: String? = nil,
        event: String? = nil,
        error: Error? = nil,
        info: String? = nil,
        UID: String? = nil,
        recUID: String? = nil
    ) {
        self.log.debug(createLogObj(message: message,
                                    function: function,
                                    event: event,
                                    error: error,
                                    info: info,
                                    UID: UID,
                                    recUID: recUID))
    }
    
    func info(
            message: String? = nil,
            function: String? = nil,
            event: String? = nil,
            error: Error? = nil,
            info: String? = nil,
            UID: String? = nil,
            recUID: String? = nil
    ) {
        self.log.info(createLogObj(message: message,
                                   function: function,
                                   event: event,
                                   error: error,
                                   info: info,
                                   UID: UID,
                                   recUID: recUID))
    }
    
    func warning(
        message: String? = nil,
        function: String? = nil,
        event: String? = nil,
        error: Error? = nil,
        info: String? = nil,
        UID: String? = nil,
        recUID: String? = nil
    ) {
        self.log.warning(createLogObj(message: message,
                                      function: function,
                                      event: event,
                                      error: error,
                                      info: info,
                                      UID: UID,
                                      recUID: recUID))
    }
    
    func error(
        message: String? = nil,
        function: String? = nil,
        event: String? = nil,
        error: Error? = nil,
        info: String? = nil,
        UID: String? = nil,
        recUID: String? = nil
    ) {
        self.log.error(createLogObj(message: message,
                                      function: function,
                                      event: event,
                                      error: error,
                                      info: info,
                                      UID: UID,
                                      recUID: recUID))
        
    }
}
