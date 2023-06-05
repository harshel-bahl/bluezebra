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
    @Binding var scene: String
    
    var body: some View {
        
        VStack {
            
            if (scene == "inactive" || scene == "background") {
                
                Color("background2")
                    .ignoresSafeArea()
                
            } else if (scene == "active") {
                
                if (tab == "teams") {
                    
                    NavigationView {
                        VStack(spacing: 0) {
                            
                            if SP.topSafeAreaInset != 0 {
                                Color("background2")
                                    .frame(width: SP.width,
                                           height: SP.topSafeAreaInset)
                            }
                            
                            TeamsList()
                                .frame(width: SP.width,
                                       height: getHeight(type: "mainView"))
                            
                            CustomTabView(tab: $tab)
                                .frame(width: SP.width,
                                       height: getHeight())
                            
                            if SP.bottomSafeAreaInset != 0 {
                                Color("background1")
                                    .frame(width: SP.width,
                                           height: SP.bottomSafeAreaInset)
                            } else {
                                Color("background1")
                                    .frame(width: SP.width,
                                           height: SP.safeAreaHeight*0.09*0.2)
                            }
                        }
                        .ignoresSafeArea()
                    }
                    
                } else if (tab == "channels") {
                    
                    NavigationView {
                        VStack(spacing: 0) {
                            
                            Color("background1")
                                .frame(width: SP.width,
                                       height: SP.topSafeAreaInset)
                            
                            ChannelsList()
                            
                            CustomTabView(tab: $tab)
                            
                            Color("background3")
                                .frame(height: SP.bottomSafeAreaInset)
                        }
                        .ignoresSafeArea()
                    }
                    
                } else if (tab == "profile") {
                    
                    NavigationView {
                        
                        VStack(spacing: 0) {
                            
                            Color("background1")
                                .frame(width: SP.width,
                                       height: SP.topSafeAreaInset)
                            
                            ProfileHome()
                            
                            CustomTabView(tab: $tab)
                            
                            Color("background3")
                                .frame(height: SP.bottomSafeAreaInset)
                        }
                        .ignoresSafeArea()
                    }
                }
            }
        }
    }
    
    func getHeight(type: String? = nil) -> CGFloat {
        if SP.bottomSafeAreaInset != 0 {
            if type == "mainView" {
                return SP.safeAreaHeight*0.925
            } else {
                return SP.safeAreaHeight*0.075
            }
        } else {
            if type == "mainView" {
                return SP.safeAreaHeight*0.91
            } else {
                return SP.safeAreaHeight*0.09 - SP.safeAreaHeight*0.09*0.2
            }
        }
    }
}

