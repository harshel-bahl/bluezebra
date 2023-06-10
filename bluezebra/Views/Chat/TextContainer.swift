//
//  TextContainer.swift
//  bluezebra
//
//  Created by Harshel Bahl on 08/04/2023.
//

import SwiftUI

struct TextContainer: View {
    
    @EnvironmentObject var SP: ScreenProperties
    
    let channel: SChannel
    let message: SMessage
    let containerStyle: TextCellStyle
    
    @State var messageTextWidth: CGFloat = 0
    @State var timeTextWidth: CGFloat = 0
    @State var receiptColour = Color.gray
    
    var body: some View {
        basicMessage
    }
    
    var basicMessage: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            Text(message.message)
                .font(containerStyle.font)
                .fontWeight(containerStyle.fontWeight)
                .foregroundColor(message.isSender ? Color.white : Color.black)
                .overlay {
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear() {
                                messageTextWidth = geometry.size.width
                            }
                    }
                }
            
            HStack(alignment: .bottom, spacing: 0) {
                
                Circle()
                    .fill(receiptColour)
                    .frame(width: 7.5, height: 7.5)
                
                Spacer(minLength: 15)
                
                Text(DateU.shared.timeHm(date: message.date))
                    .font(.system(size: 12.5))
                    .frame(height: 12.5)
                    .foregroundColor(.white)
                    .fixedSize()
            }
            .padding(.top, 7.5)
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
        .padding(SP.width*0.0125)
        .background(message.isSender ? Color("blueAccent1") : Color("greyAccent1"))
        .cornerRadius(7.5)
        .frame(width: SP.width*0.666, alignment: message.isSender ? .trailing : .leading)
        .padding(.horizontal, SP.width*0.033)
        .padding(.vertical, 1)
        .frame(width: SP.width, alignment: message.isSender ? .trailing : .leading)
        .onAppear() {
            getReceiptColour()
        }
    }
    
    func getReceiptColour() {
        if channel.channelType == "personal" {
            receiptColour = Color("darkAccent1")
        } else {
            if let messageStatus = message.sent {
                let userIDs = messageStatus.components(separatedBy: ",")
            }
        }
    }
}


