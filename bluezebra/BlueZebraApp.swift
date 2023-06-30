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
    var body: some Scene {
        WindowGroup {
            SPView(backgroundColour: Color("background1")) {
//                TopLevelView()
                ButtonAni(label: "harshel",
                           fontSize: 14,
                           fontWeight: .bold,
                           foregroundColour: .white,
                           BGColour: .accentColor,
                           action: {
                    print("hello")
                })
            }
        }
    }
}

