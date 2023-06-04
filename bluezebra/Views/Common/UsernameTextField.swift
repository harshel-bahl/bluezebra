//
//  UsernameTextField.swift
//  bluezebra
//
//  Created by Harshel Bahl on 04/06/2023.
//

import SwiftUI

struct UsernameTextField: View {
    
    @ObservedObject var userDC = UserDC.shared
    @ObservedObject var usernameTextManager = TextBindingManager(limit: 13)
    
    @FocusState var usernameField: Bool
    
    var body: some View {
        TextField("Username",
                  text: $usernameTextManager.username,
                  onEditingChanged: { isEditing in
            if isEditing {
            }
        },
                  onCommit: {
            let username = usernameTextManager.username.replacingOccurrences(of: "@", with: "")
            
            userDC.checkUsername(username: username) { result in
                switch result {
                case .success(let result): break
                    //                                        withAnimation(.easeInOut(duration: 0.3)) {
                    //                                            self.checkedUsername = result
                    //                                        }
                case .failure(_): break
                }
            }
        })
        .autocapitalization(.none)
        .disableAutocorrection(true)
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .foregroundColor(Color("text3"))
        .scrollContentBackground(.hidden)
        .font(.headline)
        .fontWeight(.regular)
        .focused($usernameField)
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
