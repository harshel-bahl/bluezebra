//
//  InputContainer.swift
//  bluezebra
//
//  Created by Harshel Bahl on 17/07/2023.
//

import SwiftUI
import ExyteMediaPicker
import FilePicker
import Kingfisher

struct InputContainer: View {
    
    @EnvironmentObject var chatState: ChatState
    
    // Text
    @State var message = ""
    
    // Images
    @State var selectedImages: [UIImage]?
    
    @State var showMediaPicker = false
    
    @State var initialTFSize: CGSize?
    @State var TFSize: CGSize = .zero
    
    @FocusState var focusedField: String?
    
    let BG: Color
    
    let placeholder: String
    let textColour: Color
    let fontSize: CGFloat
    let lineLimit: Int
    
    let iconSize: CGSize
    let iconColour: Color
    
    let spacing: CGFloat
    let outerPadding: EdgeInsets
    
    let imagePreviewSize: CGSize
    let imagePreviewBG: Color
    let imagePreviewCR: CGFloat
    
    init(BG: Color = Color("background1"),
         placeholder: String = "message",
         textColour: Color = Color("text1"),
         fontSize: CGFloat = 18,
         lineLimit: Int = 7,
         iconSize: CGSize = .init(width: 27.5, height: 27.5),
         iconColour: Color = Color("accent1"),
         spacing: CGFloat = 10,
         outerPadding: EdgeInsets = .init(top: 10, leading: 12.5, bottom: 10, trailing: 12.5),
         focusedField: FocusState<String?>,
         imagePreviewSize: CGSize = .init(width: 70, height: 85),
         imagePreviewBG: Color = .black,
         imagePreviewCR: CGFloat = 7.5) {
        self.BG = BG
        self.placeholder = placeholder
        self.textColour = textColour
        self.fontSize = fontSize
        self.lineLimit = lineLimit
        self.iconSize = iconSize
        self.iconColour = iconColour
        self.spacing = spacing
        self.outerPadding = outerPadding
        self._focusedField = focusedField
        self.imagePreviewSize = imagePreviewSize
        self.imagePreviewBG = imagePreviewBG
        self.imagePreviewCR = imagePreviewCR
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            Divider()
            
            VStack(spacing: 0) {
                if let selectedImages = selectedImages,
                   !selectedImages.isEmpty {
                    HStack(spacing: 0) {
                        ForEach(selectedImages.indices, id: \.self) { index in
                            Image(uiImage: selectedImages[index])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: imagePreviewSize.width, height: imagePreviewSize.height)
                                .background() { imagePreviewBG }
                                .cornerRadius(imagePreviewCR)
                        }
                    }
                }
                
                HStack(alignment: .bottom, spacing: spacing) {
                    
                    fileButton
                    
                    cameraButton
                    
                    ChildSizeReader(size: $TFSize) {
                        messageEditor
                            .edgePadding(bottom: {
                                if let initialTFSize = initialTFSize {
                                    return (iconSize.height/2 - initialTFSize.height/2)
                                } else {
                                    return 0
                                }
                            }())
                    }
                    .onAppear() {
                        initialTFSize = TFSize
                    }
                    
                    sendButton
                }
            }
            .padding(outerPadding)
        }
        .background() { BG }
        .sheet(isPresented: $showMediaPicker, content: {
            MediaPicker(isPresented: $showMediaPicker, onChange: { media in
                
                Task {
                    var images = [Data]()
                    
                    for image in media {
                        if let imageData = await image.getData() {
                            images.append(imageData)
                        }
                    }
                    
                    let uiImages = images.compactMap() { image in
                        return UIImage(data: image)
                    }
                    
                    selectedImages = uiImages
                }
            })
        })
        
    }
    
    var fileButton: some View {
        FilePicker(types: [.plainText], allowMultiple: false) { urls in
            
        } label: {
            SystemIcon(systemName: "folder.circle.fill",
                       size: iconSize,
                       colour: iconColour,
                       BGColour: Color("background1"),
                       applyClip: true,
                       shadow: 1)
        }
    }
    
    var cameraButton: some View {
        SystemIcon(systemName: "camera.circle.fill",
                   size: iconSize,
                   colour: iconColour,
                   BGColour: Color("background1"),
                   applyClip: true,
                   shadow: 1,
                   buttonAction: {
            showMediaPicker = true
        })
    }
    
    var messageEditor: some View {
        SubmitTextField(text: $message,
                        placeholder: placeholder,
                        foregroundColour: textColour,
                        font: .system(size: fontSize),
                        axis: .vertical,
                        lineLimit: lineLimit,
                        autocorrection: true)
        .focused($focusedField, equals: "message")
        .onAppear {
            focusedField = "message"
        }
    }
    
    var sendButton: some View {
        SystemIcon(systemName: message.isEmpty ? "arrow.up.circle" : "arrow.up.circle.fill",
                   size: iconSize,
                   colour: iconColour,
                   BGColour: Color("background1"),
                   applyClip: true,
                   shadow: 1,
                   buttonAction: {
            Task {
                
                self.message.removeAll()
            }
        })
        .disabled(message.isEmpty)
    }
    
}

