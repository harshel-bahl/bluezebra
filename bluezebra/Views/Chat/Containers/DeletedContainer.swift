//
//  DeletedContainer.swift
//  bluezebra
//
//  Created by Harshel Bahl on 17/07/2023.
//

import SwiftUI

struct DeletedContainer: View {
    
    @EnvironmentObject var SP: ScreenProperties
    @EnvironmentObject var chatState: ChatState
    
    let message: SMessage
    
    let deletedReceiptIcon: String
    let completedDeletionIcon: String
    let receiptSize: CGSize
    let receiptColour: Color
    
    let dateColour: Color
    let dateFont: Font
    
    let removeButtonSpacing: CGFloat
    let bubbleWidth: CGFloat
    let bubbleSpacing: CGFloat
    let bubblePadding: EdgeInsets
    let BG: Color
    let cornerRadius: CGFloat
    let outerPadding: EdgeInsets
    
    init(message: SMessage,
         deletedReceiptIcon: String = "trash.circle",
         completedDeletionIcon: String = "checkmark.circle",
         receiptSize: CGSize = .init(width: 30, height: 30),
         receiptColour: Color = .white,
         dateColour: Color = .white,
         dateFont: Font = .system(size: 12.5),
         removeButtonSpacing: CGFloat = 10,
         bubbleWidth: CGFloat = 75,
         bubbleSpacing: CGFloat = 7.5,
         bubblePadding: EdgeInsets = .init(top: 10, leading: 10, bottom: 5, trailing: 5),
         BG: Color = Color("accent1"),
         cornerRadius: CGFloat = 15,
         outerPadding: EdgeInsets = .init(top: 1, leading: 10, bottom: 1, trailing: 10)) {
        self.message = message
        self.deletedReceiptIcon = deletedReceiptIcon
        self.completedDeletionIcon = completedDeletionIcon
        self.receiptSize = receiptSize
        self.receiptColour = receiptColour
        self.dateColour = dateColour
        self.dateFont = dateFont
        self.removeButtonSpacing = removeButtonSpacing
        self.bubbleWidth = bubbleWidth
        self.bubbleSpacing = bubbleSpacing
        self.bubblePadding = bubblePadding
        self.BG = BG
        self.cornerRadius = cornerRadius
        self.outerPadding = outerPadding
    }
    
    var body: some View {
        deletedContainer
            .padding(bubblePadding)
            .background { BG }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .frame(width: bubbleWidth)
            .padding(outerPadding)
            .frame(width: SP.screenWidth, alignment: .trailing)
    }
    
    var deletedContainer: some View {
        
        HStack(spacing: removeButtonSpacing) {
            
            if let remoteDeleted = message.remoteDeleted?.components(separatedBy: ","),
               chatState.currChannel.userID == remoteDeleted[0] {
                SystemIcon(systemName: "trash",
                           colour: receiptColour)
            }
            
            VStack(spacing: bubbleSpacing) {
                HStack(spacing: 0) {
                    if let remoteDeleted = message.remoteDeleted?.components(separatedBy: ","),
                       chatState.currChannel.userID == remoteDeleted[0] {
                        SystemIcon(systemName: completedDeletionIcon,
                                   size: receiptSize,
                                   colour: receiptColour)
                    } else {
                        SystemIcon(systemName: deletedReceiptIcon,
                                   size: receiptSize,
                                   colour: receiptColour)
                    }
                    
                    Spacer()
                }
                
                HStack(alignment: .bottom, spacing: 0) {
                    if message.isSender {
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
            }
        }
    }
}


