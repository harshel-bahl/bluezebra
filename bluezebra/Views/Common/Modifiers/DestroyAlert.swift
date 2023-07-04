//
//  DestroyAlert.swift
//  bluezebra
//
//  Created by Harshel Bahl on 30/06/2023.
//

import SwiftUI

struct DestroyAlert: ViewModifier {
    
    let title: String
    @Binding var showAlert: Bool
    let cancelAction: ()->()
    let destroyAction: ()->()
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: _showAlert, actions: {
                
                Button("Cancel", role: .cancel, action: {
                    cancelAction()
                })
                
                Button("Destroy", role: .destructive, action: {
                    destroyAction()
                })
            })
    }
}

extension View {
    
    func destroyAlert(title: String,
                      showAlert: Binding<Bool>,
                      cancelAction: @escaping ()->(),
                      destroyAction: @escaping ()->()) -> some View {
        modifier(DestroyAlert(title: title,
                              showAlert: showAlert,
                              cancelAction: cancelAction,
                              destroyAction: destroyAction))
    }
}

