//
//  ImageContainer.swift
//  bluezebra
//
//  Created by Harshel Bahl on 17/07/2023.
//

import SwiftUI

struct ImageContainer: View {
    
    @EnvironmentObject var SP: ScreenProperties
    @EnvironmentObject var chatState: ChatState
    @ObservedObject var messageDC = MessageDC.shared
    
    let message: SMessage
    
    let fetchMaxDimension: CGFloat
    let imageMaxHeight: CGFloat
    let soleImageMaxWidth: Double
    let imageWithTextMaxWidth: Double
    let imageMinWidth: CGFloat
    let imageMinHeight: CGFloat
    
    let textColour: Color
    let textSize: CGFloat
    let lineLimit: ClosedRange<Int>
    
    let messageStatus: String?
    let receiptSize: CGSize?
    
    let dateColour: Color
    let dateFont: Font
    
    let imageWithTextSpacing: CGFloat
    let messageWithTextPadding: EdgeInsets
    let bubblePadding: EdgeInsets
    let BG: [Color]
    let placeholderBG: Color
    let cornerRadius: CGFloat
    let outerPadding: EdgeInsets
    
    let showContextMenu: Bool
    
    @State var image: UIImage?
    
    init(message: SMessage,
         fetchMaxDimension: CGFloat = 250,
         imageMaxHeight: CGFloat = 325,
         soleImageMaxWidth: CGFloat = 280,
         imageWithTextMaxWidth: CGFloat = 300,
         imageMinWidth: CGFloat = 225,
         imageMinHeight: CGFloat = 200,
         textColour: Color = .white,
         textSize: CGFloat = 17.5,
         lineLimit: ClosedRange<Int> = 0...3,
         messageStatus: String? = nil,
         receiptSize: CGSize = .init(width: 7.5, height: 7.5),
         dateColour: Color = .white,
         dateFont: Font = .system(size: 12.5),
         imageWithTextSpacing: Double = 7.5,
         messageWithTextPadding: EdgeInsets = EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5),
         bubblePadding: EdgeInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5),
         BG: [Color] = [Color("accent1"), Color("accent3")],
         placeholderBG: Color = Color("accent5"),
         cornerRadius: CGFloat = 15,
         outerPadding: EdgeInsets = .init(top: 1, leading: 10, bottom: 1, trailing: 10),
         showContextMenu: Bool = true) {
        self.message = message
        self.fetchMaxDimension = fetchMaxDimension
        self.imageMaxHeight = imageMaxHeight
        self.soleImageMaxWidth = soleImageMaxWidth
        self.imageWithTextMaxWidth = imageWithTextMaxWidth
        self.imageMinWidth = imageMinWidth
        self.imageMinHeight = imageMinHeight
        self.textColour = textColour
        self.textSize = textSize
        self.lineLimit = lineLimit
        self.messageStatus = messageStatus
        self.receiptSize = receiptSize
        self.dateColour = dateColour
        self.dateFont = dateFont
        self.imageWithTextSpacing = imageWithTextSpacing
        self.messageWithTextPadding = messageWithTextPadding
        self.bubblePadding = bubblePadding
        self.BG = BG
        self.placeholderBG = placeholderBG
        self.cornerRadius = cornerRadius
        self.outerPadding = outerPadding
        self.showContextMenu = showContextMenu
    }
    
    var body: some View {
        imageMessage
    }
    
    var imageMessage: some View {
        ZStack {
            if message.message == "" {
                soleImage
                    .background(message.isSender ? BG[0] : BG[1])
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                
                    .if(showContextMenu == true, transform: { view in
                        view
                            .contextMenu {
                                Button("Delete Message", action: {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        Task {
                                            if chatState.currChannel.channelType == "personal" {
//                                                try? await messageDC.messageDeletion(channelID: chatState.currChannel.channelID,
//                                                                                     message: message)
                                            } else {
                                                
                                            }
                                        }
                                    }
                                })
                            }
                    })
                        
                        .frame(width: soleImageMaxWidth, alignment: message.isSender ? .trailing : .leading)
                        .padding(outerPadding)
                        .frame(width: SP.screenWidth, alignment: message.isSender ? .trailing : .leading)
            } else {
                imageWithMessage
                    .background(message.isSender ? BG[0] : BG[1])
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
                
                    .if(showContextMenu == true, transform: { view in
                        view
                            .contextMenu {
                                Button("Delete Message", action: {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        Task {
                                            if chatState.currChannel.channelType == "personal" {
//                                                try? await messageDC.messageDeletion(channelID: chatState.currChannel.channelID,
//                                                                                     message: message)
                                            } else {
                                                
                                            }
                                        }
                                    }
                                })
                            }
                    })
                        
                        .frame(width: imageWithTextMaxWidth, alignment: message.isSender ? .trailing : .leading)
                        .padding(outerPadding)
                        .frame(width: SP.screenWidth, alignment: message.isSender ? .trailing : .leading)
            }
        }
        .onAppear {
            Task {
                let imageID = message.imageIDs?.components(separatedBy: ",")[0]
                self.image = try await DataPC.shared.scaledImage(imageName: imageID,
                                                                 intermidDirs: [chatState.currChannel.channelID.uuidString, "images"],
                                                                 maxDimension: fetchMaxDimension)
            }
        }
    }
    
    var soleImage: some View {
        ZStack {
            if let image = self.image {
                BZImage(uiImage: image,
                        aspectRatio: .fill,
                        width: calculateSize(image: image).width,
                        height: calculateSize(image: image).height)
            } else {
                placeholderBG
            }
        }
        .overlay {
            VStack(spacing: 0) {
                Spacer()
                
                metaDataStack
                    .background(Color.black
                        .opacity(0.5)
                        .shadow(color: .black, radius: 15)
                        .blur(radius: 12.5, opaque: false))
                    .padding(bubblePadding)
            }
        }
    }
    
    var imageWithMessage: some View {
        VStack(spacing: imageWithTextSpacing) {
            ZStack {
                if let image = self.image {
                    BZImage(uiImage: image,
                            aspectRatio: .fill,
                            width: calculateSize(image: image).width,
                            height: calculateSize(image: image).height,
                            cornerRadius: cornerRadius)
                } else {
                    placeholderBG
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            
            FixedText(text: message.message!,
                      colour: textColour,
                      fontSize: textSize,
                      lineLimit: lineLimit,
                      padding: messageWithTextPadding,
                      multilineAlignment: .leading,
                      pushText: .leading)
            
            metaDataStack
        }
        .padding(bubblePadding)
    }
    
    func calculateSize(image: UIImage) -> CGSize {
        if message.message == "" { // sole image
            if image.size.width > image.size.height { // horizontal image
                return CGSize(width: soleImageMaxWidth,
                              height: max(image.size.height, imageMinHeight))
            } else { // vertical image
                return CGSize(width: max(image.size.width, imageMinWidth),
                              height: imageMaxHeight)
            }
        } else { // image with text
            if image.size.width > image.size.height { // horizontal image
                return CGSize(width: imageWithTextMaxWidth - bubblePadding.leading - bubblePadding.trailing,
                              height: max(image.size.height, imageMinHeight))
            } else { // vertical image
                return CGSize(width: imageWithTextMaxWidth,
                              height: imageMaxHeight)
            }
        }
    }
    
    var metaDataStack: some View {
        HStack(alignment: .bottom, spacing: 0) {
            if message.isSender {
                if messageStatus == "sent" {
                    Circle()
                        .fill(.yellow)
                        .frame(width: receiptSize?.width, height: receiptSize?.height)
                } else if messageStatus == "delivered" || messageStatus == "read" {
                    Circle()
                        .fill(messageStatus == "read" ? .green : .gray)
                        .frame(width: receiptSize?.width, height: receiptSize?.height)
                    
                    Circle()
                        .fill(messageStatus == "read" ? .green : .gray)
                        .frame(width: receiptSize?.width, height: receiptSize?.height)
                        .edgePadding(leading: 2)
                }
                
                Spacer(minLength: 15)
                
                Text(DateU.shared.timeHm(date: message.date))
                    .font(dateFont)
                    .foregroundColor(dateColour)
            } else {
                Text(DateU.shared.timeHm(date: message.date))
                    .font(dateFont)
                    .foregroundColor(dateColour)
                
                Spacer(minLength: 15)
            }
        }
    }
}

struct TopCornerRoundedShape: Shape {
    var cornerRadius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: 0, y: cornerRadius)) // Left side starting point
        path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false) // Top left corner
        path.addLine(to: CGPoint(x: rect.maxX - cornerRadius, y: 0)) // Top edge
        path.addArc(center: CGPoint(x: rect.maxX - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .degrees(270), endAngle: .degrees(0), clockwise: false) // Top right corner
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY)) // Right edge
        path.addLine(to: CGPoint(x: 0, y: rect.maxY)) // Bottom edge
        path.closeSubpath()
        
        return path
    }
}
