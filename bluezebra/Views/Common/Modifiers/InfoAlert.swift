//
//  InfoAlert.swift
//  bluezebra
//
//  Created by Harshel Bahl on 04/07/2023.
//

import SwiftUI

struct InfoAlert: ViewModifier {
    let title: String
    @Binding var showAlert: Bool
    let cancelAction: () -> ()
    @ViewBuilder var message: () -> Text
    
    func body(content: Content) -> some View {
        content
            .alert(title,
                   isPresented: $showAlert,
                   actions: {
                Button("Ok", role: .cancel, action: {
                    cancelAction()
                })
            }, message: message)
    }
}

extension View {
    func infoAlert(title: String,
                   showAlert: Binding<Bool>,
                   cancelAction: @escaping () -> (),
                   message: @escaping () -> Text) -> some View {
        modifier(InfoAlert(title: title,
                           showAlert: showAlert,
                           cancelAction: cancelAction,
                           message: message))
    }
}


