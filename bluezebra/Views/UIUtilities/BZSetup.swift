//
//  BZSetup.swift
//  bluezebra
//
//  Created by Harshel Bahl on 27/06/2023.
//

import Foundation

class BZSetup {
    
    static let shared = BZSetup()
    
    let removeUsernameValues: Set<String> = [".", ",", "+", "-", "/", "*", "^", "%", "(", ")", "{", "}", "@", ";", ":", "?"]
}
