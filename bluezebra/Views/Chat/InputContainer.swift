//
//  InputContainer.swift
//  bluezebra
//
//  Created by Harshel Bahl on 08/04/2023.
//

import SwiftUI
import ExyteMediaPicker
import FilePicker

struct InputContainer: View {
    
    @ObservedObject var messageDC = MessageDC.shared
    
    @EnvironmentObject var SP: ScreenProperties
    
    @State var message = ""
    @State var selectedImages = [Media]()
    
    @State var TFSize: CGSize = .zero
    
    @State var initialTFSize: CGSize?
    
    @State var visibleLineCount = 1
    
    @FocusState var focusedField: Field?
    
    @State var showMediaPicker = false
    
    enum Field {
        case message
    }
    
    let channel: SChannel
    
    var body: some View {
        VStack(spacing: 0) {
            
            Divider()
            
            ZStack {
                
                ChildSizeReader(size: $TFSize) {
                    messageEditor
                        .padding(.top, SP.safeAreaHeight*0.01)
                        .padding(.bottom, SP.safeAreaHeight*0.01)
                        .padding(.leading, SP.width*0.033 + SP.width*0.025*2 + ((initialTFSize?.height ?? SP.width*0.1) - SP.safeAreaHeight*0.025)*2)
                        .padding(.trailing, SP.width*0.033 + SP.width*0.025 + (initialTFSize?.height ?? SP.width*0.1) - SP.safeAreaHeight*0.025)
                }
                
                VStack(spacing: 0) {
                    Spacer(minLength: 0)
                        .frame(height: {
                            if let initialSize = initialTFSize {
                                return TFSize.height - initialSize.height
                            } else {
                                return nil
                            }
                        }())
                    
                    HStack(spacing: 0) {
                        fileButton
                            .padding(.trailing, SP.width*0.025)
                        
                        cameraButton
                            .padding(.trailing, SP.width*0.025)
                        
                        Color.clear
                        
                        sendButton
                            .padding(.leading, SP.width*0.025)
                    }
                    .padding(.top, SP.safeAreaHeight*0.01)
                    .padding(.bottom, SP.safeAreaHeight*0.01)
                    .padding(.leading, SP.width*0.033)
                    .padding(.trailing, SP.width*0.033)
                    .frame(height: {
                        if let initialSize = initialTFSize {
                            return initialSize.height
                        } else {
                            return nil
                        }
                    }())
                }
            }
            .background { Color("background1") }
            .onAppear { self.initialTFSize = TFSize }
        }
        .sheet(isPresented: $showMediaPicker) {
            MediaPicker(isPresented: $showMediaPicker,
                        onChange: { selectedImages = $0 })
        }
    }
    
    var fileButton: some View {
        FilePicker(types: [.plainText], allowMultiple: false) { urls in
            
        } label: {
            Image(systemName: "folder.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color("blueAccent1"))
                .frame(width: (initialTFSize?.height ?? SP.width*0.1) - SP.safeAreaHeight*0.025,
                       height: (initialTFSize?.height ?? SP.width*0.1) - SP.safeAreaHeight*0.025)
        }
    }
    
    var cameraButton: some View {
        Button(action: {
            showMediaPicker = true
        }, label: {
            Image(systemName: "camera.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color("blueAccent1"))
                .frame(width: (initialTFSize?.height ?? SP.width*0.1) - SP.safeAreaHeight*0.025,
                       height: (initialTFSize?.height ?? SP.width*0.1) - SP.safeAreaHeight*0.025)
        })
    }
    
    var messageEditor: some View {
        TextField("message",
                  text: $message,
                  axis: .vertical)
        .autocapitalization(.none)
        .keyboardType(.alphabet)
        .disableAutocorrection(true)
        .lineLimit(6)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .foregroundColor(Color("text2"))
        .font(.body)
        .fontWeight(.regular)
        .focused($focusedField, equals: .message)
        .onAppear() {
            focusedField = .message
        }
    }
    
    var sendButton: some View {
        Button(action: {
            if channel.channelID == "personal" {
                Task() {
                    if !message.isEmpty {
                        let sMessage = try? await messageDC.createMessage(message: message,
                                                                          type: "text",
                                                                          date: DateU.shared.currDT)
                        if let sMessage = sMessage { messageDC.personalMessages.insert(sMessage, at: 0) }
                        
                        self.message.removeAll()
                    }
                }
            }
        }, label: {
            Image(systemName: message.isEmpty ? "arrow.up.circle" : "arrow.up.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color("blueAccent1"))
                .frame(width: (initialTFSize?.height ?? SP.width*0.1) - SP.safeAreaHeight*0.025,
                       height: (initialTFSize?.height ?? SP.width*0.1) - SP.safeAreaHeight*0.025)
        })
        .disabled(message.isEmpty)
    }
}

