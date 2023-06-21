//
//  SignUp.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 09/01/2023.
//

import SwiftUI
import EmojiPicker

struct SignUp: View {
    
    @ObservedObject var userDC = UserDC.shared
    @ObservedObject var channelDC = ChannelDC.shared
    @EnvironmentObject var SP: ScreenProperties
    
    @ObservedObject var usernameTM = UsernameTextManager(limit: 13, text: "@")
    
    @State var selectedEmoji: Emoji?
    @State var displayEmojiPicker = false
    @State var displayUsernameBlock = false
    @State var pin: String = ""
    @State var firstPin: String = ""
    @State var checkedUsername: Bool? = nil
    @State var createUserSuccess = false
    @State var failure = false
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case username
        case pin
    }
    
    var body: some View {
        ZStack {
            
            Color("background4")
                .ignoresSafeArea()
            
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    
                    VStack(spacing: 0) {
                        VStack(spacing: 0) {
                            
                            // BZ logo
                            
                            HStack {
                                simpleText(text: "Step 1",
                                           colour: Color("text1"),
                                           fontWeight: .bold,
                                           font: .largeTitle)
                                
                                Spacer()
                            }
                            .id(1)
                            .padding(SP.width*0.08)
                            
                            
                            VStack(spacing: 0) {
                                HStack(spacing: 0) {
                                    simpleText(text: "Choose an avatar",
                                               colour: Color("text1"),
                                               fontWeight: .regular,
                                               font: .headline)
                                    
                                    Spacer()
                                }
                                .padding(.top, SP.width*0.04)
                                .padding(.leading, SP.width*0.08 - SP.width*0.033)
                                .padding(.bottom, SP.width*0.05)
                                
                                avatarButton
                                    .padding(.bottom, SP.width*0.05)
                                
                            }
                            .background() { Color("background2") }
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color("blueAccent1"), lineWidth: 2)
                            )
                            .shadow(radius: 1)
                            .padding(.leading, SP.width*0.033)
                            .padding(.trailing, SP.width*0.033)
                            .padding(.bottom, SP.width*0.08)
                            
                            
                            VStack(spacing: 0) {
                                if let _ = selectedEmoji {
                                    VStack(spacing: 0) {
                                        HStack(spacing: 0) {
                                            simpleText(text: "Choose a username",
                                                       colour: Color("text1"),
                                                       fontWeight: .regular,
                                                       font: .headline)
                                            
                                            Spacer()
                                        }
                                        .padding(.top, SP.width*0.04)
                                        .padding(.leading, SP.width*0.08 - SP.width*0.033)
                                        .padding(.bottom, SP.width*0.05)
                                        
                                        VStack(spacing: 0) {
                                            GeometryReader { geometry in
                                                HStack(spacing: 0) {
                                                    usernameTextfield
                                                        .frame(width: geometry.size.width*0.666)
                                                    
                                                    checkUsernameBadge
                                                        .frame(width: geometry.size.width*0.066)
                                                        .padding(.leading)
                                                }
                                                .frame(width: geometry.size.width, height: geometry.size.height)
                                            }
                                            .frame(height: SP.safeAreaHeight*0.066)
                                            
                                            if let _ = checkedUsername, checkedUsername == false {
                                                Text("Username unavailable :(")
                                                    .foregroundColor(Color("orangeAccent1"))
                                                    .fontWeight(.regular)
                                            }
                                        }
                                        .padding(.bottom, SP.width*0.05)
                                    }
                                    .background() { Color("background2") }
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color("blueAccent1"), lineWidth: 2)
                                    )
                                    .shadow(radius: 1)
                                    .padding(.leading, SP.width*0.033)
                                    .padding(.trailing, SP.width*0.033)
                                    .onAppear() {
                                        DispatchQueue.main.asyncAfter(deadline: .now()+0.75) {
                                            withAnimation() {
                                                focusedField = .username
                                            }
                                        }
                                    }
                                    
                                    if let checkedUsername = checkedUsername, checkedUsername == true {
                                        continueButton1(proxy: proxy)
                                            .padding(.top, SP.width*0.08)
                                    }
                                }
                            }
                            .animation(.easeInOut(duration: 0.33).delay(0.25), value: selectedEmoji)
                            
                            Spacer()
                        }
                        .frame(width: SP.width, height: SP.safeAreaHeight)
                        
                        VStack(spacing: 0) {
                            GeometryReader { geometry in
                                VStack(spacing: 0) {
                                    HStack(spacing: 0) {
                                        simpleText(text: "Step 2",
                                                   colour: Color("text1"),
                                                   fontWeight: .bold,
                                                   font: .largeTitle)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            withAnimation() {
                                                resetPin()
                                                focusedField = nil
                                                proxy.scrollTo(1, anchor: .top)
                                            }
                                        }, label: {
                                            Text("back")
                                                .font(.subheadline)
                                                .fontWeight(.bold)
                                                .foregroundColor(Color("orangeAccent1"))
                                            
                                            Image(systemName: "arrow.up.circle")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: SP.width/15)
                                                .foregroundColor(Color("orangeAccent1"))
                                                .padding(.leading, SP.width*0.001)
                                        })
                                    }
                                    .padding(SP.width*0.08)
                                    
                                    VStack(spacing: 0) {
                                        pinEntryText1
                                            .padding(.leading, SP.width*0.08)
                                            .padding(.trailing, SP.width*0.08)
                                            .padding(.bottom, SP.width*0.08)
                                            .padding(.bottom, SP.width*0.05)
                                            .padding(.top, SP.width*0.04)
                                        
                                        pinBoxes
                                            .padding(.bottom, SP.width*0.08)
                                    }
                                    .background() { Color("background2") }
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color("blueAccent1"), lineWidth: 2)
                                    )
                                    .shadow(radius: 1)
                                    .padding(.leading, SP.width*0.033)
                                    .padding(.trailing, SP.width*0.033)
                                    .onTapGesture {
                                        if focusedField != .pin { focusedField = .pin }
                                    }
                                    
                                    VStack(spacing: 0) {
                                        if firstPin.count == 4 && pin.count == 4,
                                           firstPin == pin {
                                            createUserButton
                                                .padding(.top, SP.width*0.08)
                                        } else if firstPin.count == 4 && pin.count == 4,
                                                  firstPin != pin {
                                            pinFailure
                                                .padding()
                                            
                                            retryPinButton
                                        }
                                    }
                                    .animation(.easeInOut(duration: 0.2), value: pin)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .id(2)
                        .frame(width: SP.width, height: SP.safeAreaHeight)
                    }
                    .frame(height: SP.safeAreaHeight*2)
                }
                .scrollDisabled(true)
                .ignoresSafeArea(.keyboard)
            }
            
            if createUserSuccess == true {
                SuccessView1()
            }
        }
        .sheet(isPresented: $displayEmojiPicker) {
            emojiPickerView
                .presentationDetents([.height(SP.height*0.5)])
        }
        .alert("Unable to create user", isPresented: $failure) {
            Button("Try again", role: .cancel) {
            }
        }
    }
    
    func simpleText(text: String,
                    colour: Color,
                    fontWeight: Font.Weight,
                    font: Font) -> some View {
        let text = Text(text)
            .font(font)
            .fontWeight(fontWeight)
            .foregroundColor(colour)
        
        return text
    }
    
    var avatarButton: some View {
        Button(action: {
            displayEmojiPicker = true
        }) {
            if let selectedEmoji = selectedEmoji {
                Text(selectedEmoji.value)
                    .font(.system(size: SP.width*0.125))
                    .frame(height: SP.width*0.15)
            } else {
                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: SP.width*0.15)
                    .foregroundColor(Color("blueAccent1"))
            }
        }
    }
    
    var emojiPickerView: some View {
        EmojiPickerView(selectedEmoji: $selectedEmoji,
                        selectedColor: .blue,
                        emojiProvider: BZEmojiProvider1())
            .padding()
    }
    
    var usernameTextfield: some View {
        let textfield = TextField("Username",
                                  text: $usernameTM.username,
                                  onEditingChanged: { isEditing in
            if isEditing {
                if self.checkedUsername != nil {
                    withAnimation(.easeInOut(duration: 0.2)) { self.checkedUsername = nil }
                }
            }
        },
                                  onCommit: {
            let username = usernameTM.username.replacingOccurrences(of: "@", with: "")
            
            userDC.checkUsername(username: username) { result in
                switch result {
                case .success(let result):
                    withAnimation(.easeInOut(duration: 0.3)) {
                        self.checkedUsername = result
                    }
                case .failure(_): break
                }
            }
        })
            .autocapitalization(.none)
            .disableAutocorrection(true)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .foregroundColor(Color("text3"))
            .scrollContentBackground(.hidden)
            .font(.headline)
            .fontWeight(.regular)
            .focused($focusedField, equals: .username)
            .submitLabel(.go)
            .onChange(of: usernameTM.username) { username in
                if username.isEmpty {
                    usernameTM.username = username + "@"
                } else if username.first != "@" {
                    usernameTM.username.insert("@", at: usernameTM.username.startIndex)
                }
            }
        
        return textfield
    }
    
    @ViewBuilder
    var checkUsernameBadge: some View {
        if let _ = checkedUsername, checkedUsername == true {
            Image(systemName: "checkmark.seal.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color("blueAccent1"))
        } else if let _ = checkedUsername, checkedUsername == false {
            Image(systemName: "exclamationmark.triangle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color("orangeAccent1"))
        } else {
            EmptyView()
        }
    }
    
    func continueButton1(proxy: ScrollViewProxy) -> some View {
        let button = Button(action: {
            withAnimation() {
                proxy.scrollTo(2, anchor: .top)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                withAnimation() {
                    focusedField = .pin
                }
            }
        }, label: {
            Text("Continue")
                .font(.system(size: 16, design: .rounded))
                .padding()
                .background(Color("blueAccent1"))
                .foregroundColor(Color.white)
                .clipShape(Capsule())
                .shadow(radius: 1)
        })
        
        return button
    }
    
    var pinEntryText1: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                simpleText(text: firstPin.count == 4 ? "Retype your pin" : "Create a pin",
                           colour: Color("text1"),
                           fontWeight: .regular,
                           font: .headline)
                
                Spacer()
            }
            .padding(.bottom, SP.width*0.05)
            
            HStack(spacing: 0) {
                simpleText(text: "Pick something memorable! There's no other way to access your data",
                           colour: Color("text1"),
                           fontWeight: .regular,
                           font: .caption)
                
                Spacer()
            }
            .frame(height: SP.safeAreaHeight*0.04)
        }
    }
    
    var pinBoxes: some View {
        HStack(spacing: 0) {
            ForEach(0 ..< 4, id: \.self) { index in
                pinBoxes(index)
            }
        }
        .frame(width: SP.width*0.75)
        .background(content: {
            TextField("", text: $pin.limit(4))
                .keyboardType(.numberPad)
                .frame(width: 1, height: 1)
                .opacity(0.001)
                .blendMode(.screen)
                .focused($focusedField, equals: .pin)
        })
    }
    
    @ViewBuilder
    func pinBoxes(_ index: Int) -> some View {
        ZStack{
            if pin.count > index {
                let startIndex = pin.startIndex
                let charIndex = pin.index(startIndex, offsetBy: index)
                let charToString = String(pin[charIndex])
                Text(charToString)
            } else {
                Text("")
            }
        }
        .frame(width: SP.width*0.125, height: SP.width*0.125)
        .background() { Color("background2") }
        .cornerRadius(5)
        .overlay {
            let status = (focusedField == .pin && pin.count == index)
            
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .stroke(Color("blueAccent1"), lineWidth: status ? 2 : 0.5)
                .animation(.easeInOut(duration: 0.2), value: focusedField)
        }
        .shadow(radius: 1)
        .frame(maxWidth: .infinity)
        .onChange(of: pin) { pin in
            if pin.count == 4 && firstPin == "" {
                withAnimation {
                    self.pin = ""
                    firstPin = pin
                }
            }
            
            if firstPin.count == 4 && self.pin.count == 4,
               firstPin == self.pin {
                focusedField = nil
            }
        }
    }
    
    var createUserButton: some View {
        let button = Button(action: {
            
            let username = usernameTM.username.replacingOccurrences(of: "@", with: "")
            
            userDC.createUser(username: username,
                              pin: pin,
                              avatar: selectedEmoji!.name) { result in
                
                withAnimation { createUserSuccess = true }
                
                DispatchQueue.main.asyncAfter(deadline: .now()+2.5) {
                    switch result {
                    case .success(let userData):
                        userDC.userData = userData
                        userDC.loggedIn = true
                    case .failure(_):
                        self.failure = true
                    }
                }
            }
        }, label: {
            Text("Create User")
                .font(.system(size: 16, design: .rounded))
                .padding()
                .background(Color("blueAccent1"))
                .foregroundColor(Color.white)
                .clipShape(Capsule())
                .shadow(radius: 1)
        })
        
        return button
    }
    
    var pinFailure: some View {
        let text = simpleText(text: "Pin doesn't match :(",
                              colour: Color("orangeAccent1"),
                              fontWeight: .regular,
                              font: .subheadline)
        
        return text
    }
    
    var retryPinButton: some View {
        let button = Button(action: {
            withAnimation { resetPin() }
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
    
    func resetPin() {
        self.pin = ""
        self.firstPin = ""
    }
}




