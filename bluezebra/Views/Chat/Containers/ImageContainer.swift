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
    
    init(message: SMessage,
         textColour: [Color] = [.white, .black],
         textFont: Font = .system(size: 17.5),
         showReceipt: Bool = false,
         messageStatus: String? = nil,
         receiptSize: CGSize = .init(width: 7.5, height: 7.5),
         dateColour: [Color] = [.white, .black],
         dateFont: Font = .system(size: 12),
         bubblePadding: EdgeInsets = .init(top: 7.5, leading: 7.5, bottom: 7.5, trailing: 7.5),
         BG: [Color] = [Color("accent1"), Color("accent3")],
         cornerRadius: CGFloat = 15,
         outerPadding: EdgeInsets = .init(top: 1, leading: 15, bottom: 1, trailing: 15),
         maxWidthProp: Double = 0.6,
         showContextMenu: Bool = true) {
        self.message = message
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
        VStack(alignment: .leading, spacing: 0) {
            
            ZStack {
                if let resourceID = message.resourceIDs?.components(separatedBy: ",")[0],
                   let imageData = chatState.images[resourceID],
                   let uiImage = UIImage(data: imageData) {
                    BZImage(uiImage: uiImage,
                            aspectRatio: .fill,
                            height: 250,
                            width: SP.screenWidth*maxWidthProp,
                            BG: Color("accent5"))
                    .allowsHitTesting(false)
                } else {
                    
                }
            }
            .frame(width: SP.screenWidth*maxWidthProp,
                   height: 250)
            .background() { Color("accent5")}
//            .clipShape(TopCornerRoundedShape(cornerRadius: cornerRadius))
            
            VStack(spacing: 5) {
                
                if message.message != "" {
                    Text(message.message)
                        .font(textFont)
                        .foregroundColor(message.isSender ? textColour[0] : textColour[1])
                }
                
                HStack(alignment: .bottom, spacing: 0) {
                    
                    if message.isSender {
                        if showReceipt {
                            if messageStatus == "notSent" || messageStatus == "sent" {
                                Circle()
                                    .fill(messageStatus == "sent" ? .yellow : .red)
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
            .padding(bubblePadding)
        }
        .background(message.isSender ? BG[0] : BG[1])
//        .cornerRadius(cornerRadius)
        
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
