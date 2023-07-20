//
//  SimpleSegmentAni.swift
//  bluezebra
//
//  Created by Harshel Bahl on 28/06/2023.
//

import SwiftUI

struct SimpleTextSegment: View {
    
    @Binding var selected: Int
    
    let textNames: [String]
    let fontSize: CGFloat
    
    let width: CGFloat
    
    init(selected: Binding<Int>,
         textNames: [String],
         fontSize: CGFloat = 15,
         width: CGFloat = 150,
         BGColour: Color,
         selectedBGColour: Color,
         selectedIconColour: Color = .white,
         unselectedIconColour: Color = .white) {
        self._selected = selected
        self.textNames = textNames
        self.fontSize = fontSize
        self.width = width
        UISegmentedControl.appearance().backgroundColor = UIColor(BGColour)
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(selectedBGColour)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(selectedIconColour)], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(unselectedIconColour)], for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes([.font: UIFont.systemFont(ofSize: fontSize)], for: .normal)
    }
    
    var body: some View {
        Picker("", selection: $selected) {
            ForEach(0 ..< textNames.count) { index in
                Text(textNames[index])
                    .tag(index)
            }
        }
        .pickerStyle(.segmented)
        .frame(width: width)
    }
}



