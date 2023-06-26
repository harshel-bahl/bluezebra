//
//  HomePage.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 06/01/2023.
//

import SwiftUI

struct HomePage: View {
    
    @ObservedObject var userDC = UserDC.shared
    
    @EnvironmentObject var SP: ScreenProperties
    
    @State var tab: String = "channels"
    
    @Environment(\.scenePhase) var scene
    
    var body: some View {
        
        VStack {
            
            if (scene == .inactive || scene == .background) {
                
                Color("background2")
                    .ignoresSafeArea()
                
            } else if (scene == .active) {
                
                if (tab == "teams") {
                    
                } else if (tab == "channels") {
                    
                    NavigationView {
                        VStack(spacing: 0) {
                            
                            Color("background1")
                                .frame(width: SP.screenWidth,
                                       height: SP.topSAI)
                            
                            ChannelsList()
                            
                            CustomTabView(tab: $tab)
                            
                            Color("background3")
                                .frame(height: SP.bottomSAI)
                        }
                        .ignoresSafeArea()
                    }
                    
                } else if (tab == "profile") {
                    
                    NavigationView {
                        
                        VStack(spacing: 0) {
                            
                            Color("background1")
                                .frame(width: SP.screenWidth,
                                       height: SP.topSAI)
                            
                            ProfileHome()
                            
                            CustomTabView(tab: $tab)
                            
                            Color("background3")
                                .frame(height: SP.bottomSAI)
                        }
                        .ignoresSafeArea()
                    }
                }
            }
        }
    }
}

