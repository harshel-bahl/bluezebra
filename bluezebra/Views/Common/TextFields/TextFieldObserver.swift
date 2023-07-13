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

            if let valuesToRemove = self.valuesToRemove,
               text != removeValuesFrom(string: text,
                                        valuesToRemove: valuesToRemove) {
                self.text = oldValue
            }
        }
    }
    
    @Published var debouncedText: String = ""
    
    var debounceFor: Double?
    var characterLimit: Int?
    var valuesToRemove: Set<String>?
    
    private var subscriptions = Set<AnyCancellable>()
    
    init(startingText: String? = nil,
         text: String = "",
         debounceFor: Double? = nil,
         characterLimit: Int? = nil,
         valuesToRemove: Set<String>? = nil) {
        
        self.startingText = startingText
        self.text = (startingText ?? "") + text
        self.debounceFor = debounceFor
        self.characterLimit = characterLimit
        self.valuesToRemove = (startingText != nil && valuesToRemove != nil) ? valuesToRemove!.filter({ $0 != self.startingText }) : valuesToRemove
        
        if let debounceFor = debounceFor {
            $text
                .debounce(for: .seconds(debounceFor), scheduler: DispatchQueue.main)
                .sink(receiveValue: { [weak self] text in
                    self?.debouncedText = text
                } )
                .store(in: &subscriptions)
        }
    }
    
    func removeValuesFrom(string: String, valuesToRemove: Set<String>) -> String {
        var cleanedString = string
        
        for value in valuesToRemove {
            let regex = try! NSRegularExpression(pattern: NSRegularExpression.escapedPattern(for: value))
            cleanedString = regex.stringByReplacingMatches(
                in: cleanedString,
                options: [],
                range: NSRange(location: 0, length: cleanedString.utf16.count),
                withTemplate: ""
            )
        }
        
        return cleanedString
    }
}

