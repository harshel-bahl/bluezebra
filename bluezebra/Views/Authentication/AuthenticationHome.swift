//
//  AuthenticationHome.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 02/01/2023.
//

import SwiftUI
import LocalAuthentication

struct AuthenticationHome: View {
    
    @ObservedObject var userDC = UserDC.shared
    
    @Binding var fetchedUser: Bool
    @Binding var scene: String
    
    var body: some View {
        VStack {
            
            if (fetchedUser == false) {
                
                Color("background2")
                    .ignoresSafeArea()
                
            } else if (fetchedUser == true && userDC.userData == nil) {
                
                SignUp()
                
            } else if (userDC.userData != nil && userDC.loggedIn == false) {
                
                Login(scene: $scene)
                
            }
        }
    }
}


