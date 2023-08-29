//
//  AppDelegate.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 22/01/2023.
//

import SwiftUI
import SwiftyBeaver

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        let console = ConsoleDestination()
        let file = FileDestination()
        
        console.format = "$DHH:mm:ss$d $C$L$c: $M"
        file.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $L: $M"
        
        log.addDestination(console)
        log.addDestination(file)
        
        return true
    }
}
