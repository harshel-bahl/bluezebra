//
//  SimpleSegmentAni.swift
//  bluezebra
//
//  Created by Harshel Bahl on 28/06/2023.
//

import SwiftUI

struct SimpleSegmentAni: View {
    
    @Binding var selected: Int
    
    let imageNames: [String]?
    let textNames: [String]?
    
    let width: CGFloat
    let height: CGFloat?
    let elementPadding: CGFloat?
    
    init(selected: Binding<Int>,
         imageNames: [String]? = nil,
         textNames: [String]? = nil,
         width: CGFloat = 150,
         height: CGFloat? = nil,
         BGColour: Color,
         selectedBGColour: Color,
         selectedIconColour: Color = .white,
         unselectedIconColour: Color = .white,
         elementPadding: CGFloat? = nil) {
        self._selected = selected
        self.imageNames = imageNames
        self.textNames = textNames
        self.width = width
        self.height = height
        UISegmentedControl.appearance().backgroundColor = UIColor(BGColour)
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(selectedBGColour)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(selectedIconColour)], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(unselectedIconColour)], for: .normal)
        self.elementPadding = elementPadding
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
            .frame(width: width,
                   height: height)
            
        } else if let imageNames = self.imageNames {
            
            Picker("", selection: $selected) {
                ForEach(0 ..< imageNames.count) { index in
                    Image(systemName: imageNames[index])
                        .tag(index)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: width,
                   height: height)
        }
    }
}



