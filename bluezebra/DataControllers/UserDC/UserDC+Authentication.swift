//
//  UserDC+Authentication.swift
//  bluezebra
//
//  Created by Harshel Bahl on 19/04/2023.
//

import Foundation
import LocalAuthentication

extension UserDC {
    
    /// pinAuth
    ///
    func pinAuth(pin: String) throws -> Bool {
        
        guard let storedPin = self.userSettings?.pin else { throw DCError.nilError(func: "UserDC.pinAuth", err: "userSettings is nil") }
        
        if storedPin == pin {
            return true
        } else {
            throw DCError.authFailure(func: "UserDC.pinAuth", err: "pin was incorrect")
        }
    }
    
    /// biometricAuth
    ///
    func biometricAuth(completion: @escaping (Result<Void, DCError>)->()) {
        
        let context = LAContext()
        var error: NSError?
        
        guard let userSettings = self.userSettings else {
            completion(.failure(DCError.nilError(func: "UserDC.biometricAuth", err: "userSettings is nil")))
            return
        }
        
        guard userSettings.biometricSetup == "active" else {
            completion(.failure(DCError.authFailure(func: "UserDC.biometricAuth", err: "biometrics is not active")))
            return
        }
        
        if (context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) && self.userSettings?.biometricSetup=="active") {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "We need to unlock your data.") { success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        completion(.success(()))
                    } else {
                        completion(.failure(DCError.authFailure(func: "UserDC.biometricAuth", err: "biometrics failed")))
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(.failure(DCError.authFailure(func: "UserDC.biometricAuth", err: "biometrics are unavailable")))
            }
        }
    }
    
    /// setupBiometricAuth
    ///
    func setupBiometricAuth(completion: @escaping (Result<Void, DCError>)->()) {
        
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "Setup Biometrics for Authentication") { success, authenticationError in
                if success {
                    Task {
                        do {
                            let userSettings = try await DataPC.shared.updateMO(entity: Settings.self,
                                                                                property: ["biometricSetup"],
                                                                                value: ["active"])
                            
                            DispatchQueue.main.async {
                                self.userSettings = userSettings
                            }
                            
                            completion(.success(()))
                        } catch {
                            completion(.failure(DCError.authFailure(func: "UserDC.setupBiometricAuth", err: error.localizedDescription)))
                        }
                    }
                } else {
                    completion(.failure(DCError.authFailure(func: "UserDC.setupBiometricAuth", err: authenticationError?.localizedDescription ?? "biometric failed")))
                }
            }
        } else {
            Task {
                do {
                    let userSettings = try await DataPC.shared.updateMO(entity: Settings.self,
                                                                        property: ["biometricSetup"],
                                                                        value: ["inactive"])
                    DispatchQueue.main.async {
                        self.userSettings = userSettings
                    }
                    
                    completion(.success(()))
                } catch {
                    completion(.failure(DCError.authFailure(func: "UserDC.setupBiometricAuth", err: error.localizedDescription)))
                }
            }
        }
    }
    
    /// cancelBiometricAuthSetup
    ///
    func cancelBiometricAuthSetup() async throws {
        
        guard let userSettings = self.userSettings else {
            throw DCError.nilError(func: "UserDC.biometricAuth", err: "userSettings is nil")
        }
        
        guard userSettings.biometricSetup == "active" else {
            throw DCError.authFailure(func: "UserDC.biometricAuth", err: "biometrics is not active")
        }
        
        let SMO = try await DataPC.shared.updateMO(entity: Settings.self,
                                                   property: ["biometricSetup"],
                                                   value: ["inactive"])
        
        DispatchQueue.main.async {
            self.userSettings = SMO
        }
        
    }
}

