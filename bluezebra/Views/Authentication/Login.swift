//
//  Login.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 10/01/2023.
//

import SwiftUI

struct Login: View {
    
    @ObservedObject var userDC = UserDC.shared
    
    @EnvironmentObject var SP: ScreenProperties
    
    @State var pin: String = ""
    @State var showRetryPinButton = false
    @State var faceIDFailed = false
    
    @Binding var scene: String
    
    @FocusState var focusedField: Field?
    
    enum Field {
        case logIn
    }
    
    var body: some View {
        
        if scene == "active" {
            
            ZStack {
                
                Color("background4")
                    .ignoresSafeArea()
                
                if userDC.userSettings?.biometricSetup==true && faceIDFailed == false {
                    
                    faceID
                    
                } else {
                    
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            (
                                Text("Hello ")
                                    .foregroundColor(Color("text1"))
                                    .font(.largeTitle) +
                                
                                Text("@")
                                    .foregroundColor(Color("blueAccent1"))
                                    .font(.largeTitle) +
                                
                                Text(userDC.userData!.username)
                                    .foregroundColor(Color("text1"))
                                    .font(.largeTitle)
                            )
                            
                            Spacer()
                        }
                        .padding(.leading, SP.width*0.08)
                        .padding(.top, SP.safeAreaHeight*0.08)
                        .padding(.bottom, SP.safeAreaHeight*0.08)
                        
                        VStack(spacing: 0) {
                            pinBoxes
                                .onAppear() {
                                    focusedField = .logIn
                                }
                                .padding(SP.width*0.05)
                        }
                        .frame(maxWidth: .infinity)
                        .background() { Color("background2") }
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color("blueAccent1"), lineWidth: 2)
                        )
                        .shadow(radius: 1)
                        .padding(.leading, SP.width*0.08)
                        .padding(.trailing, SP.width*0.08)
                        
                        VStack(spacing: 0) {
                            if showRetryPinButton {
                                Text("Incorrect Pin :(")
                                    .foregroundColor(Color("orangeAccent1"))
                                    .fontWeight(.regular)
                                    .padding()
                                
                                retryPinButton
                            }
                        }
                        .animation(.easeInOut(duration: 0.3), value: showRetryPinButton)
                        
                        TextField("", text: $pin.limit(4))
                            .keyboardType(.numberPad)
                            .frame(width: 1, height: 1)
                            .opacity(0.001)
                            .blendMode(.screen)
                            .focused($focusedField, equals: .logIn)
                        
                        Spacer()
                        
                    }
                }
            }
        }
        else {
            Color("background2r")
                .ignoresSafeArea()
        }
    }
    
    var faceID: some View {
        Color("background2")
            .edgesIgnoringSafeArea(.all)
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
    
    var pinBoxes: some View {
        HStack(spacing: 0) {
            ForEach(0 ..< 4, id: \.self) { index in
                
                if index != 0 { Spacer() }
                
                pinBoxes(index)
                
                if index != 3 { Spacer() }
            }
        }
        .frame(width: SP.width*0.75)
        .onChange(of: pin) { pin in
            if self.pin.count == 4 {
                userDC.pinAuth(pin: self.pin) { result in
                    switch result {
                    case .success():
                        focusedField = nil
                        userDC.loggedIn = true
                    case .failure(_):
                        showRetryPinButton = true
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func pinBoxes(_ index: Int) -> some View {
        ZStack(alignment: .center) {
            if pin.count > index {
                Text("*")
                    .font(.system(size: 40))
                    .foregroundColor(Color("text1"))
                    .fontWeight(.bold)
                    .offset(y: 7.5)
            } else {
                Text("")
            }
        }
        .frame(width: SP.width*0.125, height: SP.width*0.125)
        .background() { Color("background2") }
        .cornerRadius(5)
        .overlay {
            let status = (focusedField == .logIn && pin.count == index)
            
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(Color("blueAccent1"), lineWidth: status ? 2 : 0.5)
                .animation(.easeInOut(duration: 0.2), value: focusedField)
        }
        .shadow(radius: 1)
    }
    
    var retryPinButton: some View {
        let button = Button(action: {
            withAnimation {
                showRetryPinButton = false
                self.pin = ""
            }
        }, label: {
            Text("Retry Pin")
                .font(.system(size: 16, design: .rounded))
                .padding()
                .background(Color("orangeAccent1"))
                .foregroundColor(Color.white)
                .clipShape(Capsule())
                .shadow(radius: 1)
        })
        
        return button
    }
}



