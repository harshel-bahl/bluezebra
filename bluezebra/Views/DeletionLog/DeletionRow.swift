//
//  DeletionRow.swift
//  bluezebra
//
//  Created by Harshel Bahl on 15/07/2023.
//

import SwiftUI

struct DeletionRow: View {
    
    @EnvironmentObject var SP: ScreenProperties
    
    let CD: SChannelDeletion
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                    EmojiIcon(avatar: CD.icon,
                              size: .init(width: 40, height: 40),
                              emojis: BZEmojiProvider1.shared.getAll(),
                    buttonAction: { icon in })
                    .edgePadding(trailing: 15)
                
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        FixedText(text: "@" + CD.name,
                                  colour: Color("accent1"),
                                  fontSize: 18)
                        
                        Spacer()
                        
                        DateTimeMed(date: CD.deletionDate,
                                    fontSize: 15,
                                    colour: Color("text2"))
                    }
                    .edgePadding(bottom: 5)
                    
                    HStack(spacing: 0) {
                        if CD.type == "clear" {
                            FixedText(text: "Type: Clean Channel",
                                      colour: Color("text2"),
                                      fontSize: 12.5)
                        } else if CD.type == "delete" {
                            FixedText(text: "Type: Channel Deletion",
                                      colour: Color("text2"),
                                      fontSize: 12.5)
                        }
                        
                        Spacer()
                    }
                    .edgePadding(bottom: 2.5)
                    
                    HStack(spacing: 0) {
                        if CD.isOrigin {
                            FixedText(text: "Origin: Me",
                                      colour: Color("text2"),
                                      fontSize: 12.5)
                        } else {
                            FixedText(text: "Origin: " + CD.name,
                                      colour: Color("text2"),
                                      fontSize: 12.5)
                        }
                        
                        Spacer()
                    }
                    .edgePadding(bottom: 2.5)
                    
                    HStack(spacing: 0) {
                        if CD.toDeleteUserIDs.components(separatedBy: ",").isEmpty {
                            FixedText(text: "Status: ",
                                      colour: Color("text2"),
                                      fontSize: 12.5)
                            
                            FixedText(text: "Completed",
                                      colour: Color.green,
                                      fontSize: 12.5)
                        } else {
                            FixedText(text: "Status: ",
                                      colour: Color("text2"),
                                      fontSize: 12.5)
                            
                            FixedText(text: "Incomplete",
                                      colour: Color("orangeAccent1"),
                                      fontSize: 12.5)
                        }
                        
                        Spacer()
                    }
                }
            }
            .edgePadding(top: 12.5, bottom: 12.5, leading: 20, trailing: 20)
           
            HStack(spacing: 0) {
                Spacer()
                
                VStack(spacing: 0) {
                    Divider()
                        .frame(width: SP.screenWidth - 7.5 - 15 - 2.5 - 45 - 12.5)
                }
            }
        }
    }
}


