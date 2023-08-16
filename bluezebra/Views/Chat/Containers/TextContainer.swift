//
//  TextContainer.swift
//  bluezebra
//
//  Created by Harshel Bahl on 08/04/2023.
//

import SwiftUI
import ScreenshotPreventingSwiftUI

struct TextContainer: View {
    
    @EnvironmentObject var SP: ScreenProperties
    @EnvironmentObject var chatState: ChatState
    @ObservedObject var messageDC = MessageDC.shared
    
    let message: SMessage
    
    let textColour: Color
    let textFont: Font
    
    let messageStatus: String?
    let receiptSize: CGSize?
    
    let dateColour: Color
    let dateFont: Font
    
    let imageWithTextSpacing: CGFloat
    let bubblePadding: EdgeInsets
    let BG: [Color]
    let cornerRadius: CGFloat
    let outerPadding: EdgeInsets
    let maxWidth: Double
    
    let showContextMenu: Bool
    
    @State var messageTextWidth: CGFloat = 0
    @State var timeTextWidth: CGFloat = 0
    
    init(message: SMessage,
         textColour: Color = .white,
         textFont: Font = .system(size: 17.5),
         messageStatus: String? = nil,
         receiptSize: CGSize = .init(width: 7.5, height: 7.5),
         dateColour: Color = .white,
         dateFont: Font = .system(size: 12.5),
         imageWithTextSpacing: Double = 7.5,
         bubblePadding: EdgeInsets = .init(top: 5, leading: 5, bottom: 5, trailing: 5),
         BG: [Color] = [Color("accent1"), Color("accent3")],
         cornerRadius: CGFloat = 15,
         outerPadding: EdgeInsets = .init(top: 1, leading: 10, bottom: 1, trailing: 10),
         maxWidth: Double = 300,
         showContextMenu: Bool = true) {
        self.message = message
        self.textColour = textColour
        self.textFont = textFont
        self.messageStatus = messageStatus
        self.receiptSize = receiptSize
        self.dateColour = dateColour
        self.dateFont = dateFont
        self.imageWithTextSpacing = imageWithTextSpacing
        self.bubblePadding = bubblePadding
        self.BG = BG
        self.cornerRadius = cornerRadius
        self.outerPadding = outerPadding
        self.maxWidth = maxWidth
        self.showContextMenu = showContextMenu
    }
    
    var body: some View {
        basicMessage
    }
    
    var basicMessage: some View {
        VStack(alignment: .leading, spacing: imageWithTextSpacing) {
            
            Text(message.message)
                .font(textFont)
                .foregroundColor(textColour)
                .overlay {
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear() {
                                messageTextWidth = geometry.size.width
                            }
                    }
                }
            
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
                        .fixedSize()
                } else {
                    Text(DateU.shared.timeHm(date: message.date))
                        .font(dateFont)
                        .foregroundColor(dateColour)
                        .fixedSize()
                    
                    Spacer(minLength: 15)
                }
            }
            .overlay {
                GeometryReader { geometry in
                    Color.clear
                        .onAppear() {
                            timeTextWidth = geometry.size.width
                        }
                }
            }
            .frame(width: {
                if messageTextWidth >= timeTextWidth {
                    return messageTextWidth
                } else {
                    return timeTextWidth
                }
            }())
            
        }
        .padding(bubblePadding)
        .background(message.isSender ? BG[0] : BG[1])
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        
        .if(showContextMenu == true, transform: { view in
            view
                .contextMenu {
                    Button("Delete Message", action: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            Task {
                                if chatState.currChannel.channelID == "personal" {
                                    try? await messageDC.messageDeletion(channelID: chatState.currChannel.channelID,
                                                                         message: message)
                                } else {
                                    
                                }
                            }
                        }
                    })
                }
        })
            
            .frame(width: maxWidth, alignment: message.isSender ? .trailing : .leading)
            .padding(outerPadding)
            .frame(width: SP.screenWidth, alignment: message.isSender ? .trailing : .leading)
            
    }
}


