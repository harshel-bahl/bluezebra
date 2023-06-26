//
//  BZTextField.swift
//  bluezebra
//
//  Created by Harshel Bahl on 04/06/2023.
//

import SwiftUI

struct BZTextField: View {
    
    var placeholder: String
    var startingText: String?
    
    @Binding var text: String
    @State var oldText: String?
    
    var foregroundColour: Color
    var font: Font
    var fontWeight: Font.Weight?
    
    var axis: Axis?
    var border: Color?
    var submitLabel: SubmitLabel?
    var keyboardType: UIKeyboardType?
    var characterLimit: Int?
    var lineLimit: Int?
    var autocapitalisation: Bool
    var autocorrection: Bool
    var trimOnCommit: Bool
    var replaceStartingOnCommit: Bool
    
    var preprocessActions: ((String)->(String))?
    var commitAction: (String)->()
    
    init(placeholder: String,
         startingText: String? = nil,
         text: Binding<String>,
         foregroundColour: Color,
         font: Font,
         fontWeight: Font.Weight? = nil,
         axis: Axis? = nil,
         border: Color? = nil,
         submitLabel: SubmitLabel? = nil,
         keyboardType: UIKeyboardType? = nil,
         characterLimit: Int? = nil,
         lineLimit: Int? = nil,
         autocapitalisation: Bool = false,
         autocorrection: Bool = false,
         trimOnCommit: Bool = false,
         replaceStartingOnCommit: Bool = false,
         preprocessActions: ((String)->(String))? = nil,
         commitAction: @escaping (String)->()) {
        self.placeholder = placeholder
        self.startingText = startingText
        self._text = Binding(projectedValue: text)
        self.foregroundColour = foregroundColour
        self.font = font
        self.fontWeight = fontWeight
        self.axis = axis
        self.border = border
        self.submitLabel = submitLabel
        self.keyboardType = keyboardType
        self.characterLimit = characterLimit
        self.lineLimit = lineLimit
        self.autocapitalisation = autocapitalisation
        self.autocorrection = autocorrection
        self.trimOnCommit = trimOnCommit
        self.replaceStartingOnCommit = replaceStartingOnCommit
        self.preprocessActions = preprocessActions
        self.commitAction = commitAction
    }
    
    
    var body: some View {
        
        textField
            .textFieldStyle(.roundedBorder)
            .scrollContentBackground(.hidden)
            .autocorrectionDisabled(autocapitalisation==true ? false : true)
            .disableAutocorrection(autocorrection==true ? false : true)
            .foregroundColor(foregroundColour)
            .font(font)
            .if(fontWeight != nil, transform: { view in view.fontWeight(fontWeight) })
                .if(border != nil, transform: { view in view.border(border!) })
                .if(keyboardType != nil, transform: { view in view.keyboardType(keyboardType!) })
                .if(lineLimit != nil, transform: { view in view.lineLimit(lineLimit) })
                .onAppear() {
                if let startingText = startingText,
                   text.isEmpty {
                    self.text = startingText
                }
            }
            .onChange(of: text, perform: { changedText in
                if let characterLimit = characterLimit,
                   let oldText = oldText {
                    if changedText.count > characterLimit && oldText.count <= characterLimit {
                        self.text = oldText
                    }
                }
                
                if let startingText = startingText,
                   changedText.isEmpty {
                    self.text = startingText
                }
                
                if let startingText = startingText,
                   changedText.prefix(startingText.count) != startingText {
                    self.text = startingText
                }
                
                self.oldText = text
            })
            .onSubmit {
                
                var commitText = text
                
                if replaceStartingOnCommit,
                   let startingText = startingText {
                    commitText = commitText.replacingOccurrences(of: startingText, with: "")
                }
                
                if trimOnCommit {
                    commitText = commitText.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                if let preprocessActions = preprocessActions {
                    commitAction(preprocessActions(commitText))
                } else {
                    commitAction(commitText)
                }
                
            }
    }
    
    // submitLabel cannot be supplied with axis as the label just creates a new line
    @ViewBuilder var textField: some View {
        if let axis = axis {
            TextField(placeholder,
                      text: $text,
                      axis: axis)
        } else {
            TextField(placeholder,
                      text: $text)
            .if(submitLabel != nil, transform: { view in view.submitLabel(submitLabel!) })
        }
    }
}

