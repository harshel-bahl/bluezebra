//
//  Login.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 10/01/2023.
//

import SwiftUI

struct Login: View {
    
    @EnvironmentObject var SP: ScreenProperties
    
    @ObservedObject var userDC = UserDC.shared
    
    @State var pin: String = ""
    @State var showRetryPin = false
    @State var faceIDFailed = false
    
    @Environment(\.scenePhase) var scene
    
    @FocusState var focusField: String?
    
    var body: some View {
        
        if scene == .active {
            
            SafeAreaScreen(BGColour: Color("background4")) {
                
                if userDC.userSettings?.biometricSetup=="active" && faceIDFailed == false {
                    
                    faceID
                    
                } else {
                    VStack(spacing: 0) {
                        HStack(spacing: 2.5) {
                            
                            FixedText(text: "Hello ",
                                      colour: Color("text1"),
                                      fontSize: 38)
                            
                            FixedText(text: "@",
                                      colour: Color("accent1"),
                                      fontSize: 38,
                                      fontWeight: .medium)
                            
                            FixedText(text: userDC.userdata?.username ?? "",
                                      colour: Color("text1"),
                                      fontSize: 38)
                            
                            Spacer()
                        }
                        .edgePadding(top: SP.safeAreaHeight*0.075,
                                     leading: 25)
                        
                        PinBoxes(pin: $pin,
                                 outerBorder: true,
                                 focus: $focusField,
                                 focusValue: "logIn",
                                 commitAction: { pin in
                            
                            do {
                                let result = try userDC.pinAuth(pin: pin)
                                
                                focusField = nil
                                userDC.loggedIn = true
                            } catch {
                                withAnimation() { showRetryPin = true }
                            }
                        })
                        .edgePadding(top: SP.safeAreaHeight*0.07,
                                     bottom: 20)
                        
                        if showRetryPin {
                            retryButton
                        }
                        
                        Spacer()
                    }
                    .onAppear {
                        focusField = "logIn"
                    }
                }
            }
        }
    }
    
    var faceID: some View {
        Color.clear
            .onAppear() {
                userDC.biometricAuth() { result in
                    switch result {
                    case .success():
                        self.faceIDFailed = false
                    case .failure(_):
                        self.faceIDFailed = true
                    }
                }
            }
    }
    
    var retryButton: some View {
        
        VStack(spacing: 10) {
            
            FixedText(text: "Incorrect Pin",
                      colour: Color("orangeAccent1"),
                      fontSize: 16)
            
            ButtonAni(label: "Try Again",
                      fontSize: 16,
                      fontWeight: .bold,
                      foregroundColour: Color.white,
                      BGColour: Color("orangeAccent1"), padding: 16) {
                withAnimation {
                    showRetryPin = false
                    self.pin = ""
                }
            }
        }
    }
}



