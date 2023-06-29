//
//  LoadingSpinner.swift
//  bluezebra
//
//  Created by Harshel Bahl on 28/06/2023.
//

import SwiftUI

struct Spinner: View {
    
    let size: CGSize
    let colours: [Color]
    let lineWidth: CGFloat
    let rotationTime: Double
    let animationTime: Double
    let fullRotation: Angle = .degrees(360)
    static let initialDegree: Angle = .degrees(270)

    @State var spinnerStart: CGFloat = 0.0
    @State var spinnerEndS1: CGFloat = 0.03
    @State var spinnerEndS2S3: CGFloat = 0.03

    @State var rotationDegreeS1 = initialDegree
    @State var rotationDegreeS2 = initialDegree
    @State var rotationDegreeS3 = initialDegree
    
    init(size: CGSize = CGSize(width: 25, height: 25),
         colours: [Color],
         lineWidth: CGFloat = 5,
         rotationTime: Double = 0.75,
         animationTime: Double = 1.9) {
        self.size = size
        self.colours = colours
        self.lineWidth = lineWidth
        self.rotationTime = rotationTime
        self.animationTime = animationTime
    }
    
    var body: some View {
        ZStack {
            SpinnerCircle(start: spinnerStart,
                          end: spinnerEndS2S3,
                          rotation: rotationDegreeS3,
                          color: colours[0],
                          lineWidth: lineWidth)
            
            SpinnerCircle(start: spinnerStart,
                          end: spinnerEndS2S3,
                          rotation: rotationDegreeS2,
                          color: colours[1],
                          lineWidth: lineWidth)
            
            SpinnerCircle(start: spinnerStart,
                          end: spinnerEndS1,
                          rotation: rotationDegreeS1,
                          color: colours[2],
                          lineWidth: lineWidth)
        }
        .frame(width: size.width,
               height: size.height)
        .onAppear() {
            self.animateSpinner()
            
            Timer.scheduledTimer(withTimeInterval: animationTime,
                                 repeats: true) { (mainTimer) in
                self.animateSpinner()
            }
        }
    }
    
    func animateSpinner(with duration: Double, completion: @escaping (() -> Void)) {
        Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { _ in
            withAnimation(Animation.easeInOut(duration: self.rotationTime)) {
                completion()
            }
        }
    }
    
    func animateSpinner() {
        animateSpinner(with: rotationTime) { self.spinnerEndS1 = 1.0 }
        
        animateSpinner(with: (rotationTime * 2) - 0.025) {
            self.rotationDegreeS1 += fullRotation
            self.spinnerEndS2S3 = 0.8
        }
        
        animateSpinner(with: (rotationTime * 2)) {
            self.spinnerEndS1 = 0.03
            self.spinnerEndS2S3 = 0.03
        }
        
        animateSpinner(with: (rotationTime * 2) + 0.0525) { self.rotationDegreeS2 += fullRotation }
        
        animateSpinner(with: (rotationTime * 2) + 0.225) { self.rotationDegreeS3 += fullRotation }
    }
}

struct SpinnerCircle: View {
    var start: CGFloat
    var end: CGFloat
    var rotation: Angle
    var color: Color
    var lineWidth: CGFloat
    
    var body: some View {
        Circle()
            .trim(from: start, to: end)
            .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            .fill(color)
            .rotationEffect(rotation)
    }
}

