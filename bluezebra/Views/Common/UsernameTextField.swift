//
//  UsernameTextField.swift
//  bluezebra
//
//  Created by Harshel Bahl on 04/06/2023.
//

import SwiftUI

struct UsernameTextField: View {
    
    @ObservedObject var textManager: UsernameTextManager
    
    var commitAction: (String)->()
    
    init(textManager: UsernameTextManager,
         commitAction: @escaping (String)->()) {
        self._textManager = ObservedObject(wrappedValue: textManager)
        self.commitAction = commitAction
    }
    
    var body: some View {
        TextField("Username",
                  text: $textManager.username,
                  onCommit: {
            var username = textManager.username
                .replacingOccurrences(of: "@", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            commitAction(username)
        })
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .foregroundColor(Color("text3"))
        .scrollContentBackground(.hidden)
        .font(.headline)
        .fontWeight(.regular)
        .submitLabel(.go)
    }
}

class UsernameTextManager: ObservableObject {
    
    let characterLimit: Int
    
    @Published var username: String {
        didSet { // didSet works on Published but doesn't work on @State:
                // perhaps because @Published is a struct on a class with a new value each time, while @State is a class attached repeatedly to a struct?
            if username.count > characterLimit && oldValue.count <= characterLimit {
                username = oldValue
            }
            
            if username.isEmpty {
                username = "@"
            }
            
            if username.first != "@" {
                username = "@"
            }
        }
    }

    init(limit: Int,
         text: String = "@") {
        self.characterLimit = limit
        
        if text.first == "@" {
            self._username = Published(wrappedValue: text)
        } else {
            self._username = Published(wrappedValue: "@" + text)
        }
    }
}
