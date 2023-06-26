//
//  TextFieldObserver.swift
//  bluezebra
//
//  Created by Harshel Bahl on 04/06/2023.
//

import SwiftUI
import Combine

class TextFieldObserver : ObservableObject {
    @Published var startingText: String?
    
    @Published var text: String {
        didSet {
            if let characterLimit = characterLimit {
                if self.text.count > characterLimit && oldValue.count <= characterLimit {
                    self.text = oldValue
                }
            }
            
            if let startingText = self.startingText,
               self.text.isEmpty {
                self.text = startingText
            }
            
            if let startingText = startingText,
               self.text.prefix(startingText.count) != startingText {
                self.text = startingText
            }
        }
    }
    
    @Published var debouncedText: String = ""
    
    var debounceFor: Double?
    var characterLimit: Int?
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(startingText: String? = nil,
         text: String = "",
         debounceFor: Double? = nil,
         characterLimit: Int? = nil) {
        
        self.startingText = startingText
        self.text = text
        self.debounceFor = debounceFor
        self.characterLimit = characterLimit
        
        if let debounceFor = debounceFor {
            $text
                .debounce(for: .seconds(debounceFor), scheduler: DispatchQueue.main)
                .sink(receiveValue: { [weak self] text in
                    self?.debouncedText = text
                } )
                .store(in: &subscriptions)
        }
    }
}

