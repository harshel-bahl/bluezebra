//
//  SceneModifier.swift
//  bluezebra
//
//  Created by Harshel Bahl on 25/06/2023.
//

import SwiftUI

struct SceneModifier: ViewModifier {
    
    @Environment(\.self) var env
    
    @State var scene: ScenePhase?
    
    let activeAction: () -> ()
    let inactiveAction: () -> ()
    let backgroundAction: () -> ()
    
    init(activeAction: @escaping ()->(),
         inactiveAction: @escaping ()->(),
         backgroundAction: @escaping ()->()) {
        self.activeAction = activeAction
        self.inactiveAction = inactiveAction
        self.backgroundAction = backgroundAction
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: env.scenePhase) { phase in
                switch phase {
                case .active:
                    #if DEBUG
                    DataU.shared.handleSuccess(info: "scnenePhase: active")
                    #endif
                    
                    if phase == .active {
                        activeAction()
                        scene = .active
                    }
                    
                case .inactive:
                    #if DEBUG
                    DataU.shared.handleSuccess(info: "scnenePhase: inactive")
                    #endif
                    
                    if phase == .inactive && scene == .active {
                        inactiveAction()
                        scene = .inactive
                    }
                    
                case .background:
                    #if DEBUG
                    DataU.shared.handleSuccess(info: "scnenePhase: background")
                    #endif
                    
                    if phase == .background {
                        backgroundAction()
                        scene = .background
                    }
                    
                default: break
                }
            }
    }
}

extension View {
    func sceneModifier(activeAction: @escaping ()->(),
                       inactiveAction: @escaping ()->(),
                       backgroundAction: @escaping ()->()) -> some View {
        modifier(SceneModifier(activeAction: activeAction,
                               inactiveAction: inactiveAction,
                               backgroundAction: backgroundAction))
    }
}


