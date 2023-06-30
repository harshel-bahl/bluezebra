//
//  SimpleSegmentAni.swift
//  bluezebra
//
//  Created by Harshel Bahl on 28/06/2023.
//

import SwiftUI

struct SimpleSegmentAni: View {
    
    let size: CGSize
    let imageNames: [String]?
    let textNames: [String]?
    let elementPadding: CGFloat
    
    @Binding var selected: Int
    
    init(size: CGSize,
         BGColour: Color,
         selectedBGColour: Color,
         selectedIconColour: Color,
         unselectedIconColour: Color,
         imageNames: [String]? = nil,
         textNames: [String]? = nil,
         elementPadding: CGFloat,
         selected: Binding<Int>) {
        self.size = size
        UISegmentedControl.appearance().backgroundColor = UIColor(BGColour)
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(selectedBGColour)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(selectedIconColour)], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(unselectedIconColour)], for: .normal)
        self.imageNames = imageNames
        self.textNames = textNames
        self.elementPadding = elementPadding
        self._selected = selected
    }
    
    var body: some View {
        if let textNames = textNames {
            
            Picker("", selection: $selected) {
                ForEach(0 ..< textNames.count) { index in
                    Text(textNames[index])
                        .tag(index)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: size.width,
                   height: size.height)
            
        } else if let imageNames = self.imageNames {
            
            Picker("", selection: $selected) {
                ForEach(0 ..< imageNames.count) { index in
                    Image(systemName: imageNames[index])
                        .tag(index)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: size.width,
                   height: size.height)
        }
    }
}



