//
//  SimpleImageSegment.swift
//  bluezebra
//
//  Created by Harshel Bahl on 14/07/2023.
//

import SwiftUI

struct SimpleImageSegment: View {
    
    @Binding var selected: Int
    let imageNames: [String]
    let elementSize: CGSize
    let padding: EdgeInsets
    
    init(selected: Binding<Int>,
         imageNames: [String],
         elementSize: CGSize = .init(width: 25, height: 25),
         padding: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
         BGColour: Color,
         selectedBGColour: Color,
         selectedIconColour: Color = .white,
         unselectedIconColour: Color = .white) {
        self._selected = selected
        self.imageNames = imageNames
        self.elementSize = elementSize
        self.padding = padding
        UISegmentedControl.appearance().backgroundColor = UIColor(BGColour)
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(selectedBGColour)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(selectedIconColour)], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(unselectedIconColour)], for: .normal)
    }
    
    var body: some View {
        Picker("", selection: $selected) {
            ForEach(0 ..< imageNames.count) { index in
                Image(systemName: imageNames[index])
                    .frame(width: elementSize.width,
                           height: elementSize.height)
                    .padding(padding)
                    .tag(index)
            }
        }
        .pickerStyle(.segmented)
    }
}

