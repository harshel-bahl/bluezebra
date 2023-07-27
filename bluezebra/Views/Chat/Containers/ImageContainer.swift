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
    
    let imageHeight: CGFloat
    let imageWidthProp: Double
    let imageTextPadding: CGFloat
    
    let textColour: [Color]
    let textFont: Font
    
    let showReceipt: Bool
    let messageStatus: String?
    let receiptSize: CGSize?
    
    let dateColour: [Color]
    let dateFont: Font
    
    let bubblePadding: EdgeInsets
    let BG: [Color]
    let cornerRadius: CGFloat
    let outerPadding: EdgeInsets
    let maxWidthProp: Double
    
    let showContextMenu: Bool
    
    @State var messageTextWidth: CGFloat = 0
    @State var timeTextWidth: CGFloat = 0
    
    @State var image: UIImage?
    
    init(message: SMessage,
         imageHeight: CGFloat = 250,
         imageWidthProp: Double = 0.66,
         imageTextPadding: Double = 7.5,
         textColour: [Color] = [.white, .black],
         textFont: Font = .system(size: 17.5),
         showReceipt: Bool = false,
         messageStatus: String? = nil,
         receiptSize: CGSize = .init(width: 7.5, height: 7.5),
         dateColour: [Color] = [.white, .black],
         dateFont: Font = .system(size: 12.5),
         bubblePadding: EdgeInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5),
         BG: [Color] = [Color("accent1"), Color("accent3")],
         cornerRadius: CGFloat = 15,
         outerPadding: EdgeInsets = .init(top: 1, leading: 15, bottom: 1, trailing: 15),
         maxWidthProp: Double = 0.66,
         showContextMenu: Bool = true) {
        self.message = message
        self.imageHeight = imageHeight
        self.imageWidthProp = imageWidthProp
        self.imageTextPadding = imageTextPadding
        self.textColour = textColour
        self.textFont = textFont
        self.showReceipt = showReceipt
        self.messageStatus = messageStatus
        self.receiptSize = receiptSize
        self.dateColour = dateColour
        self.dateFont = dateFont
        self.bubblePadding = bubblePadding
        self.BG = BG
        self.cornerRadius = cornerRadius
        self.outerPadding = outerPadding
        self.maxWidthProp = maxWidthProp
        self.showContextMenu = showContextMenu
    }
    
    var body: some View {
        basicMessage
    }
    
    var basicMessage: some View {
        ZStack {
            
            if message.message == "" {
                soleImage
            } else {
                imageWithMessage
            }
        }
        .background(message.isSender ? BG[0] : BG[1])
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        
        .if(showContextMenu == true, transform: { view in
            view
                .contextMenu {
                    Button("Delete Message", action: {
                        messageDC.deleteMessage(messageID: message.messageID)
                    })
                }
        })
            
            .frame(width: SP.screenWidth*maxWidthProp, alignment: message.isSender ? .trailing : .leading)
            .padding(outerPadding)
            .frame(width: SP.screenWidth, alignment: message.isSender ? .trailing : .leading)
    }
    
    var soleImage: some View {
        ZStack {
            if let image = self.image {
                BZImage(uiImage: image,
                        aspectRatio: .fill,
                        height: imageHeight,
                        width: SP.screenWidth*imageWidthProp)
            }
        }
        .frame(width: SP.screenWidth*imageWidthProp,
               height: imageHeight)
        .background { Color("accent5") }
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
        .onAppear {
            Task {
                let resourceID = message.resourceIDs?.components(separatedBy: ",")[0]
                self.image = try await DataPC.shared.scaledImage(imageName: resourceID,
                                                                 intermidDirs: [chatState.currChannel.channelID, "images"],
                                                                 maxDimension: 200)
            }
        }
    }
    
    var imageWithMessage: some View {
        VStack(spacing: 0) {
            ZStack {
                if let image = self.image {
                    BZImage(uiImage: image,
                            aspectRatio: .fill,
                            height: imageHeight,
                            width: SP.screenWidth*maxWidthProp - bubblePadding.leading - bubblePadding.trailing,
                            cornerRadius: cornerRadius)
                } else {
                    Color("accent5")
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .edgePadding(bottom: imageTextPadding)
            
            FixedText(text: message.message,
                      colour: message.isSender ? textColour[0] : textColour[1],
                      fontSize: 17.5,
                      lineLimit: 0...2,
                      padding: .init(top: 7.5, leading: 5, bottom: 7.5, trailing: 5),
                      multilineAlignment: .leading,
                      pushText: .leading)
            .background(message.isSender ? BG[0].brightness(-0.1) : BG[1].brightness(-0.1))
            .clipShape(RoundedRectangle(cornerRadius: 7.5))
            .edgePadding(bottom: imageTextPadding)
            
            metaDataStack
        }
        .padding(bubblePadding)
        .onAppear {
            Task {
                let resourceID = message.resourceIDs?.components(separatedBy: ",")[0]
                self.image = try await DataPC.shared.scaledImage(imageName: resourceID,
                                                                 intermidDirs: [chatState.currChannel.channelID, "images"],
                                                                 maxDimension: 200)
            }
        }
    }
    
    var metaDataStack: some View {
        HStack(alignment: .bottom, spacing: 0) {

            if message.isSender {
                if showReceipt {
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
                }

                Spacer(minLength: 15)

                Text(DateU.shared.timeHm(date: message.date))
                    .font(dateFont)
                    .foregroundColor(dateColour[0])
                    .fixedSize()
            } else {
                Text(DateU.shared.timeHm(date: message.date))
                    .font(dateFont)
                    .foregroundColor(dateColour[0])
                    .fixedSize()

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
