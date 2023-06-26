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
    
    var placeholder: String
    
    var foregroundColour: Color
    var font: Font
    var fontWeight: Font.Weight?
    
    var axis: Axis?
    var border: Color?
    var keyboardType: UIKeyboardType?
    var lineLimit: Int?
    var autocapitalisation: Bool
    var autocorrection: Bool
    var trimOnCommit: Bool
    var replaceStartingOnCommit: Bool
    
    var preprocessActions: ((String)->(String))?
    var debouncedAction: ((String)->())?
    
    init(text: Binding<String>,
         startingText: String? = nil,
         placeholder: String,
         foregroundColour: Color,
         font: Font,
         fontWeight: Font.Weight? = nil,
         axis: Axis? = nil,
         border: Color? = nil,
         keyboardType: UIKeyboardType? = nil,
         characterLimit: Int? = nil,
         lineLimit: Int? = nil,
         autocapitalisation: Bool = false,
         autocorrection: Bool = false,
         trimOnCommit: Bool = false,
         replaceStartingOnCommit: Bool = false,
         preprocessActions: ((String)->(String))? = nil,
         debouncedAction: ((String)->())? = nil,
         debounceFor: Double? = nil) {
        self._textFieldObserver = StateObject(wrappedValue: TextFieldObserver(startingText: startingText,
                                                                              text: text.wrappedValue,
                                                                              debounceFor: debounceFor,
                                                                              characterLimit: characterLimit))
        self._text = text
        self.placeholder = placeholder
        self.foregroundColour = foregroundColour
        self.font = font
        self.fontWeight = fontWeight
        self.axis = axis
        self.border = border
        self.keyboardType = keyboardType
        self.lineLimit = lineLimit
        self.autocapitalisation = autocapitalisation
        self.autocorrection = autocorrection
        self.trimOnCommit = trimOnCommit
        self.replaceStartingOnCommit = replaceStartingOnCommit
        self.preprocessActions = preprocessActions
        self.debouncedAction = debouncedAction
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
                .textFieldStyle(.roundedBorder)
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
    
    @ViewBuilder var textField: some View {
        if let axis = axis {
            TextField(placeholder,
                      text: $textFieldObserver.text,
                      axis: axis)
        } else {
            TextField(placeholder,
                      text: $textFieldObserver.text)
        }
    }
}

