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
    @ObservedObject var messageDC = MessageDC.shared
    
    // Text
    @State var message = ""
    
    // Images
    @State var selectedImages = [IdentifiableImage]()
    
    // Files
    @State var selectedFiles = [Data]()
    
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
         imagePreviewSize: CGSize = .init(width: 125, height: 150),
         imagePreviewBG: Color = .black,
         imagePreviewCR: CGFloat = 10) {
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
            
            VStack(spacing: 5) {
                
                if !selectedImages.isEmpty {
                    ScrollView(.horizontal,
                               showsIndicators: false) {
                        LazyHStack(spacing: 2.5) {
                            ForEach(selectedImages, id: \.id) { image in
                                
                                BZImage(uiImage: image.imageThumbnail,
                                        aspectRatio: .fill,
                                        height: imagePreviewSize.height,
                                        width: imagePreviewSize.width,
                                        cornerRadius: imagePreviewCR)
                                .allowsHitTesting(false)
                                .overlay {
                                    VStack(spacing: 0) {
                                        HStack(spacing: 0) {
                                            Spacer()
                                            
                                            SystemIcon(systemName: "xmark.circle",
                                                       size: .init(width: 22.5, height: 22.5),
                                                       colour: Color("accent1"),
                                                       padding: .init(top: 5, leading: 0, bottom: 0, trailing: 5),
                                                       BGColour: Color("accent4"),
                                                       applyClip: true,
                                                       shadow: 1,
                                                       buttonAction: {
                                                withAnimation {
                                                    if let index = self.selectedImages.firstIndex(where: { $0.id == image.id }) {
                                                        self.selectedImages.remove(at: index)
                                                    }
                                                }
                                            })
                                            .contentShape(Rectangle())
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                
                            }
                        }
                    }
                               .frame(height: imagePreviewSize.height)
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
                    var iImages = [IdentifiableImage]()
                    
                    for image in media {
                        if let imageData = await image.getData(),
                           let uiImage = UIImage(data: imageData),
                           let imageThumbnail = await image.getThumbnailData(),
                           let uiThumbnail = UIImage(data: imageThumbnail) {
                            iImages.append(IdentifiableImage(image: uiImage,
                                                            imageThumbnail: uiThumbnail))
                        }
                    }
                    
                    selectedImages = iImages
                }
            })
        })
        
    }
    
    var fileButton: some View {
        FilePicker(types: [.plainText], allowMultiple: false) { urls in
            
        } label: {
            SystemIcon(systemName: "folder.circle",
                       size: iconSize,
                       colour: iconColour,
                       fontWeight: .light,
                       BGColour: Color("accent4"),
                       applyClip: true,
                       shadow: 1.2)
        }
        .disabled(!selectedImages.isEmpty)
    }
    
    var cameraButton: some View {
        SystemIcon(systemName: "camera.circle",
                   size: iconSize,
                   colour: iconColour,
                   fontWeight: .light,
                   BGColour: Color("accent4"),
                   applyClip: true,
                   shadow: 1.2,
                   buttonAction: {
            showMediaPicker = true
        })
        .disabled(!selectedFiles.isEmpty)
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
        SystemIcon(systemName: message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
                   selectedImages.isEmpty &&
                   selectedFiles.isEmpty ? "arrow.up.circle" : "arrow.up.circle.fill",
                   size: iconSize,
                   colour: iconColour,
                   BGColour: Color("accent4"),
                   applyClip: true,
                   shadow: 1.2,
                   buttonAction: {
            Task {
                do {
                    try await handleSend(channelID: chatState.currChannel.channelID,
                                         message: self.message,
                                         selectedImages: self.selectedImages.isEmpty ? nil : self.selectedImages,
                                         selectedFiles: self.selectedFiles.isEmpty ? nil : self.selectedFiles)
                } catch {
                    
                }
            }
        })
        .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && selectedImages.isEmpty && selectedFiles.isEmpty)
    }
    
    func handleSend(channelID: String,
                    message: String,
                    selectedImages: [IdentifiableImage]? = nil,
                    selectedFiles: [Data]? = nil) async throws {
        
        if selectedImages == nil && selectedFiles == nil {
            
            let SMessage = try await messageDC.createTextMessage(channelID: chatState.currChannel.channelID,
                                                                 userID: chatState.currChannel.userID,
                                                                 message: self.message)
            
            messageDC.addMessage(channelID: chatState.currChannel.channelID,
                                 message: SMessage)
            
            self.message.removeAll()
            
        } else if let selectedImages = selectedImages {
            
            let SMessage = try await messageDC.createImageMessage(channelID: chatState.currChannel.channelID,
                                                                  userID: chatState.currChannel.userID,
                                                                  message: self.message,
                                                                  selectedImages: selectedImages)
            
            messageDC.addMessage(channelID: chatState.currChannel.channelID,
                                 message: SMessage)
            
            self.message.removeAll()
            withAnimation() { self.selectedImages = [IdentifiableImage]() }
            
        } else if let selectedFiles = selectedFiles {
            
            
        }
        
    }
}

