//
//  UserDC+Authentication.swift
//  bluezebra
//
//  Created by Harshel Bahl on 19/04/2023.
//

import Foundation
import LocalAuthentication

extension UserDC {
    
    /// User Authentication Functions
    ///
    func pinAuth(pin: String,
                 completion: ((Result<Void, DCError>)->())? = nil) {
        if (self.userData?.pin == pin) {
            print("CLIENT \(DateU.shared.logTS) -- UserDC.pinAuth: SUCCESS")
            if let completion = completion { completion(.success(())) }
        } else {
            print("CLIENT \(DateU.shared.logTS) -- UserDC.pinAuth: FAILED")
            if let completion = completion { completion(.failure(.failed)) }
        }
    }
    
    /// FaceID Log in
    ///
    func biometricAuth(completion: @escaping (Result<Void, DCError>)->()) {
        
        let context = LAContext()
        var error: NSError?
        
        if (context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) && self.userSettings!.biometricSetup=="active") {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "We need to unlock your data.") { success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        self.loggedIn = true
                        print("CLIENT \(DateU.shared.logTS) -- UserDC.biometricAuth: SUCCESS")
                        completion(.success(()))
                    } else {
                        print("CLIENT \(DateU.shared.logTS) -- UserDC.biometricAuth: FAILED (biometrics failed)")
                        completion(.failure(.failed))
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                print("CLIENT \(DateU.shared.logTS) -- UserDC.biometricAuth: FAILED (biometric unavailable)")
                completion(.failure(.failed))
            }
        }
    }
    
    func setupBiometricAuth() {
        
        //guard let userSettings = self.userSettings else { return }
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "Setup Biometrics for Authentication") { success, authenticationError in
                if success {
                    Task {
                        guard let userSettings = try? await DataPC.shared.updateMO(entity: Settings.self,
                                                                                   property: ["biometricSetup"],
                                                                                   value: [true]) else { return }
                        print("CLIENT \(DateU.shared.logTS) -- UserDC.setupBiometricAuth: SUCCESS")
                        DispatchQueue.main.async {
                            self.userSettings = userSettings
                        }
                    }
                }
            }
        } else {
            print("CLIENT \(DateU.shared.logTS) -- UserDC.setupBiometricAuth: FAILED (biometricAuth unavailable)")
            
            Task {
                guard let userSettings = try? await DataPC.shared.updateMO(entity: Settings.self,
                                                                           property: ["biometricSetup"],
                                                                           value: [false]) else { return }
                DispatchQueue.main.async {
                    self.userSettings = userSettings
                }
            }
        }
    }
    
    func cancelBiometricAuthSetup() {
        
        if self.userSettings!.biometricSetup != "inactive" {
            Task {
                guard let userSettings = try? await DataPC.shared.updateMO(entity: Settings.self,
                                                                           property: ["biometricSetup"],
                                                                           value: [false]) else { return }
                print("CLIENT \(DateU.shared.logTS) -- UserDC.cancelBiometricAuthSetup: SUCCESS")
                DispatchQueue.main.async {
                    self.userSettings = userSettings
                }
            }

        }
    }
}
