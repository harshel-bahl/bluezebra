//
//  PrivacyPolicyTab.swift
//  bluezebra
//
//  Created by Harshel Bahl on 05/06/2023.
//

import SwiftUI

struct PrivacyPolicyTab: View {
    var body: some View {
        VStack(spacing: 0) {
            
            NavBar(contentPadding: EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0),
                   content1: {
                HStack(alignment: .center, spacing: 0) {
                    
                    Spacer()
                    
                    FixedText(text: "Privacy Policy",
                              colour: Color("text1"),
                              fontSize: 16,
                              fontWeight: .bold)
                    
                    Spacer()
                }
                .frame(height: 25)
            })
            
            Spacer()
        }
        .ignoresSafeArea(edges: .top)
    }
}


