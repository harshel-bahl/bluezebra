//
//  BlueZebraApp.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 02/01/2023.
//
// My come up is looking dangerous

import SwiftUI

@main
struct BlueZebraApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
//    @Environment(\.self) var env
    
//    @State var scene = "inactive"
    
    var body: some Scene {
        WindowGroup {
            SPView(backgroundColour: Color("background1")) {
                TopLevelView()
            }
        }
//        .onChange(of: env.scenePhase) { phase in
//            switch phase {
//            case .active:
//                print("CLIENT -- scenePhase: app active")
//                scene = "active"
//
//            case .inactive:
//                print("CLIENT -- scenePhase: app inactive")
//                scene = "inactive"
//
//            case .background:
//                print("CLIENT -- scenePhase: app entered background")
//                scene = "background"
//
//            default: break
//            }
//        }
    }
}

