//
//  TopLevelTabView.swift
//  bluezebra
//
//  Created by Harshel Bahl on 13/07/2023.
//

import SwiftUI

struct TopLevelTabView<Content1: View, Content2: View>: View {
    
    @EnvironmentObject var SP: ScreenProperties
    
    @Environment(\.scenePhase) var scene
    
    let tabView: TabView1
    let tabContent: [String: () -> Content1]
    
    let notActiveBG: () -> Content2
    
    let topSafeBG: Color
    let bottomSafeBG: Color
    let tabContentBG: Color?
    
    @Binding var tab: String
    
    init(tabView: TabView1,
         tabContent: [String: () -> Content1],
         notActiveBG: @escaping () -> Content2,
         topSafeBG: Color,
         bottomSafeBG: Color,
         tabContentBG: Color? = nil,
         tab: Binding<String>) {
        self.tabView = tabView
        self.tabContent = tabContent
        self.notActiveBG = notActiveBG
        self.topSafeBG = topSafeBG
        self.bottomSafeBG = bottomSafeBG
        self.tabContentBG = tabContentBG
        self._tab = tab
    }
    
    var body: some View {
        ZStack {
            if (scene == .inactive || scene == .background) {
                
                notActiveBG()
                
            } else if (scene == .active) {
                
                NavigationStack {
                    VStack(spacing: 0) {
                        
                        topSafeBG
                            .frame(height: SP.topSAI)
                        
                        ZStack {
                            
                            if let _ = tabContentBG { tabContentBG }
                            
                            tabContent[tab]!()
                        }
                        
                        tabView
                        
                        bottomSafeBG
                            .frame(height: SP.bottomSAI)
                    }
                    .ignoresSafeArea()
                }
                
            }
        }
    }
}


