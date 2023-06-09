//
//  PinBoxes.swift
//  bluezebra
//
//  Created by Harshel Bahl on 05/06/2023.
//

import SwiftUI

struct PinBoxes: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

extension Binding where Value == String {
    
    func limit(_ length: Int) -> Self {
        if self.wrappedValue.count > length {
            DispatchQueue.main.async {
                self.wrappedValue = String(self.wrappedValue.prefix(length))
            }
        }
        
        return self
    }
}
