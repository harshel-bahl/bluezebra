//
//  SubmitTextField.swift
//  bluezebra
//
//  Created by Harshel Bahl on 26/06/2023.
//

import SwiftUI
import Combine

struct SubmitTextField: View {
    @StateObject var textFieldObserver: TextFieldObserver
    
    @Binding var text: String
    var placeholder: String?
    
    var foregroundColour: Color
    var font: Font
    var fontWeight: Font.Weight?
    
    let textFieldStyle: String
    var axis: Axis?
    var border: Color?
    var submitLabel: SubmitLabel?
    var keyboardType: UIKeyboardType?
    var lineLimit: Int?
    var autocapitalisation: Bool
    var autocorrection: Bool
    var trimOnCommit: Bool
    var replaceStartingOnCommit: Bool
    
    var preprocessActions: ((String)->(String))?
    var editingAction: ((String)->())?
    var submitAction: ((String)->())?
    
    init(text: Binding<String>,
         startingText: String? = nil,
         placeholder: String? = nil,
         foregroundColour: Color,
         font: Font,
         fontWeight: Font.Weight? = nil,
         textFieldStyle: String = "rounded",
         axis: Axis? = nil,
         border: Color? = nil,
         submitLabel: SubmitLabel? = nil,
         keyboardType: UIKeyboardType? = .alphabet,
         characterLimit: Int? = nil,
         valuesToRemove: Set<String>? = nil,
         lineLimit: Int? = nil,
         autocapitalisation: Bool = false,
         autocorrection: Bool = false,
         trimOnCommit: Bool = false,
         replaceStartingOnCommit: Bool = false,
         preprocessActions: ((String)->(String))? = nil,
         editingAction: ((String)->())? = nil,
         submitAction: ((String)->())? = nil) {
        self._textFieldObserver = StateObject(wrappedValue: TextFieldObserver(startingText: startingText,
                                                                              text: text.wrappedValue,
                                                                              characterLimit: characterLimit,
                                                                              valuesToRemove: valuesToRemove))
        self._text = text
        self.placeholder = placeholder
        self.foregroundColour = foregroundColour
        self.font = font
        self.fontWeight = fontWeight
        self.textFieldStyle = textFieldStyle
        self.axis = axis
        self.border = border
        self.submitLabel = submitLabel
        self.keyboardType = keyboardType
        self.lineLimit = lineLimit
        self.autocapitalisation = autocapitalisation
        self.autocorrection = autocorrection
        self.trimOnCommit = trimOnCommit
        self.replaceStartingOnCommit = replaceStartingOnCommit
        self.preprocessActions = preprocessActions
        self.editingAction = editingAction
        self.submitAction = submitAction
    }
    
    var body: some View {
        
        textField
            .onChange(of: self.textFieldObserver.text, perform: { changedText in
                var editingText = changedText
                
                if replaceStartingOnCommit,
                   let startingText = self.textFieldObserver.startingText {
                    editingText = editingText.replacingOccurrences(of: startingText, with: "")
                }
                
                if trimOnCommit {
                    editingText = editingText.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                
                if let preprocessActions = preprocessActions {
                    editingText = preprocessActions(editingText)
                }
                
                if self.text != editingText {
                    self.text = editingText
                }
                
                if let editingAction = editingAction {
                    editingAction(editingText)
                }
            })
            .onChange(of: self.text, perform: { changedText in
                if self.textFieldObserver.text != changedText {
                    self.textFieldObserver.text = changedText
                }
            })
            .if(self.submitAction != nil, transform: { view in
                view
                    .onSubmit {
                        var commitText = self.textFieldObserver.text
                        
                        if replaceStartingOnCommit,
                           let startingText = self.textFieldObserver.startingText {
                            commitText = commitText.replacingOccurrences(of: startingText, with: "")
                        }
                        
                        if trimOnCommit {
                            commitText = commitText.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        
                        if commitText != "",
                           let preprocessActions = preprocessActions,
                           let submitAction = submitAction {
                            
                            let preprocessedText = preprocessActions(commitText)
                            submitAction(preprocessedText)
                            
                        } else if commitText != "",
                                  let submitAction = submitAction {
                            submitAction(commitText)
                        }
                    }
            })
                .if(textFieldStyle == "rounded", transform: { view in
                    view.textFieldStyle(.roundedBorder)
                })
                    .if(textFieldStyle == "plain", transform: { view in
                        view.textFieldStyle(.plain)
                    })
                .scrollContentBackground(.hidden)
                .autocorrectionDisabled(autocapitalisation==true ? false : true)
                .disableAutocorrection(autocorrection==true ? false : true)
                .foregroundColor(foregroundColour)
                .font(font)
                .if(border != nil, transform: {
                    view in view.border(border!)
                })
                    .if(keyboardType != nil, transform: { view in
                        view.keyboardType(keyboardType!)
                    })
                        .if(lineLimit != nil, transform: { view in
                            view.lineLimit(lineLimit)
                        })
                            .if(fontWeight != nil, transform: { view in
                                view.fontWeight(fontWeight)
                            })
    }
    
    /// submitLabel cannot be supplied with axis as the label just creates a new line
    @ViewBuilder var textField: some View {
        if let axis = axis {
            TextField(placeholder ?? "",
                      text: $textFieldObserver.text,
                      axis: axis)
        } else {
            TextField(placeholder ?? "",
                      text: $textFieldObserver.text)
            .if(submitLabel != nil, transform: { view in
                view.submitLabel(submitLabel!)
            })
        }
    }
}


