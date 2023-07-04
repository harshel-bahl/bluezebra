//
//  SystemIcon.swift
//  bluezebra
//
//  Created by Harshel Bahl on 04/07/2023.
//

import SwiftUI

struct SystemIcon: View {
    
    let systemName: String
    let size: CGSize
    let colour: Color
    let padding: EdgeInsets
    
    var body: some View {
        Image(systemName: systemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size.width,
                   height: size.height)
            .foregroundColor(colour)
            .padding(padding)
    }
}

