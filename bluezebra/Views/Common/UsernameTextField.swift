//
//  UsernameTextField.swift
//  bluezebra
//
//  Created by Harshel Bahl on 04/06/2023.
//

import SwiftUI

struct UsernameTextField: View {
    
    @ObservedObject var usernameTextManager = TextBindingManager(limit: 13)
    
    var action: (String)->()
    
    var body: some View {
        TextField("Username",
                  text: $usernameTextManager.username,
                  onEditingChanged: { isEditing in
            if isEditing {
            }
        },
                  onCommit: {
            let username = usernameTextManager.username.replacingOccurrences(of: "@", with: "")
            
            action(username)
        })
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .foregroundColor(Color("text3"))
        .scrollContentBackground(.hidden)
        .font(.headline)
        .fontWeight(.regular)
        .submitLabel(.go)
        .onChange(of: usernameTextManager.username) { username in
            if username.isEmpty {
                usernameTextManager.username = username + "@"
            } else if username.first != "@" {
                usernameTextManager.username.insert("@", at: usernameTextManager.username.startIndex)
            }
        }
    }
}

class TextBindingManager: ObservableObject {
    @Published var username = "@" {
        didSet {
            if username.count > characterLimit && oldValue.count <= characterLimit {
                username = oldValue
            }
        }
    }
    let characterLimit: Int

    init(limit: Int = 5) {
        characterLimit = limit
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
