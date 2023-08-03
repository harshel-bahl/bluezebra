//
//  DebounceTextField.swift
//  bluezebra
//
//  Created by Harshel Bahl on 26/06/2023.
//

import SwiftUI

struct DebounceTextField: View {
    
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
    var debouncedAction: ((String)->())?
    
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
         keyboardType: UIKeyboardType? = .alphabet, // alphabet to remove suggestions
         characterLimit: Int? = nil,
         valuesToRemove: Set<String>? = nil,
         lineLimit: Int? = nil,
         autocapitalisation: Bool = false,
         autocorrection: Bool = false,
         trimOnCommit: Bool = false,
         replaceStartingOnCommit: Bool = false,
         preprocessActions: ((String)->(String))? = nil,
         debouncedAction: ((String)->())? = nil,
         debounceFor: Double? = nil,
         submitAction: ((String)->())? = nil) {
        self._textFieldObserver = StateObject(wrappedValue: TextFieldObserver(startingText: startingText,
                                                                              text: text.wrappedValue,
                                                                              debounceFor: debounceFor,
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
        self.debouncedAction = debouncedAction
        self.submitAction = submitAction
    }
    
    var body: some View {
        
        textField
            .if(self.debouncedAction != nil, transform: { view in
                view
                    .onReceive(textFieldObserver.$debouncedText, perform: { debouncedText in
                        var _debouncedText = debouncedText
                        
                        if replaceStartingOnCommit,
                           let startingText = self.textFieldObserver.startingText {
                            _debouncedText = _debouncedText.replacingOccurrences(of: startingText, with: "")
                        }
                        
                        if trimOnCommit {
                            _debouncedText = _debouncedText.trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        
                        if _debouncedText != "",
                           let preprocessActions = preprocessActions,
                           let debouncedAction = debouncedAction {
                            
                            let preprocessedText = preprocessActions(_debouncedText)
                            self.text = preprocessedText
                            debouncedAction(preprocessedText)
                            
                        } else if _debouncedText != "",
                                  let debouncedAction = debouncedAction {
                            
                            self.text = _debouncedText
                            debouncedAction(_debouncedText)
                            
                        }
                    })
            })
                .if(textFieldStyle == "rounded", transform: { view in
                    view.textFieldStyle(.roundedBorder)
                })
                    .if(textFieldStyle == "plain", transform: { view in
                        view.textFieldStyle(.plain)
                    })
                        .disableAutocorrection(autocorrection==true ? false : true)
                        .scrollContentBackground(.hidden)
                        .autocorrectionDisabled(autocapitalisation==true ? false : true)
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
    
    @ViewBuilder var textField: some View {
        if let axis = axis {
            TextField(placeholder ??  "",
                      text: $textFieldObserver.text,
                      axis: axis)
        } else {
            TextField(placeholder ?? "",
                      text: $textFieldObserver.text)
            .if(submitLabel != nil, transform: { view in
                view.submitLabel(submitLabel!)
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
                                self.text = preprocessedText
                                submitAction(preprocessedText)

                            } else if commitText != "",
                                      let submitAction = submitAction {

                                self.text = commitText
                                submitAction(commitText)

                            }
                        }
                })
        }
    }
}

