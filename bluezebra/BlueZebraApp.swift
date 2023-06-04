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
    
    @Environment(\.self) var env
    
    @State var scene = "inactive"
    
    @StateObject var screenProperties: ScreenProperties = ScreenProperties()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                GeometryReader { geometry in
                    Color("background1")
                        .edgesIgnoringSafeArea(.bottom)
                        .onAppear() {
                            self.screenProperties.height = UIScreen.main.bounds.height
                            self.screenProperties.width = UIScreen.main.bounds.width
                            self.screenProperties.topSafeAreaInset = geometry.safeAreaInsets.top
                            self.screenProperties.bottomSafeAreaInset = geometry.safeAreaInsets.bottom
                            self.screenProperties.safeAreaHeight = UIScreen.main.bounds.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom
                        }
                }
                
                TopLevelView(scene: $scene)
                    .environmentObject(screenProperties)
            }
        }
        .onChange(of: env.scenePhase) { phase in
            switch phase {
            case .active:
                print("CLIENT -- scenePhase: app active")
                scene = "active"
                
            case .inactive:
                print("CLIENT -- scenePhase: app inactive")
                scene = "inactive"
                
            case .background:
                print("CLIENT -- scenePhase: app entered background")
                scene = "background"
                
            default: break
            }
        }
    }
}

