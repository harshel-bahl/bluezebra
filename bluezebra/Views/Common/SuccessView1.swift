//
//  SuccessView1.swift
//  bluezebra
//
//  Created by Harshel Bahl on 17/05/2023.
//

import SwiftUI

struct SuccessView1: View {
    
    @State private var circleColorChanged = false
    @State private var SFColorChanged = false
    @State private var SFSizeChanged = false
    
    var height = UIScreen.main.bounds.height
    var width = UIScreen.main.bounds.width
    
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .dark))
                .edgesIgnoringSafeArea(.all)
            
            Circle()
                .frame(width: width*0.5, height: width*0.5)
                .foregroundColor(circleColorChanged ? Color("blueAccent1") : .white)
            
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(SFColorChanged ? .white : Color("blueAccent1"))
                .font(.system(size: width*0.25))
                .scaleEffect(SFSizeChanged ? 1.0 : 0.5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear() {
            withAnimation(.easeInOut(duration: 2)) {
                circleColorChanged = true
                SFColorChanged = true
                SFSizeChanged = true
            }
        }
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}



