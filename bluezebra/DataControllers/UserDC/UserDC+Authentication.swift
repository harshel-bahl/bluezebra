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
        
        let storedPin = try DataPC.shared.retrievePassword(account: "userPin")
        
        if storedPin == pin {
            return true
        } else {
            throw DCError.authFailure(err: "pin was incorrect")
        }
    }
    
    /// biometricAuth
    ///
    func biometricAuth(completion: @escaping (Result<Void, DCError>)->()) {
        
        let context = LAContext()
        var error: NSError?
        
        guard let userSettings = self.userSettings else {
            completion(.failure(DCError.nilError(err: "userSettings is nil")))
            return
        }
        
        guard userSettings.biometricSetup == "active" else {
            completion(.failure(DCError.authFailure(err: "biometrics is not active")))
            return
        }
        
        if (context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) && self.userSettings?.biometricSetup=="active") {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "We need to unlock your data.") { success, authenticationError in
                
                DispatchQueue.main.async {
                    if success {
                        completion(.success(()))
                    } else {
                        completion(.failure(DCError.authFailure(err: "biometrics failed")))
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                completion(.failure(DCError.authFailure(err: "biometrics are unavailable")))
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
                            let userSettings = try await DataPC.shared.backgroundPerformSync() {
                                let MO = try DataPC.shared.updateMO(entity: Settings.self,
                                                                    property: ["biometricSetup"],
                                                                    value: ["active"])
                                return try MO.safeObject()
                            }
                            
                            DispatchQueue.main.async {
                                self.userSettings = userSettings
                            }
                            
                            completion(.success(()))
                        } catch {
                            completion(.failure(DCError.authFailure(err: error.localizedDescription)))
                        }
                    }
                } else {
                    completion(.failure(DCError.authFailure(err: authenticationError?.localizedDescription ?? "biometric failed")))
                }
            }
        } else {
            Task {
                do {
                    let userSettings = try await DataPC.shared.backgroundPerformSync() {
                        let MO = try DataPC.shared.updateMO(entity: Settings.self,
                                                            property: ["biometricSetup"],
                                                            value: ["inactive"])
                        return try MO.safeObject()
                    }
                    
                    DispatchQueue.main.async {
                        self.userSettings = userSettings
                    }
                    
                    completion(.success(()))
                } catch {
                    completion(.failure(DCError.authFailure(err: error.localizedDescription)))
                }
            }
        }
    }
    
    /// cancelBiometricAuthSetup
    ///
    func cancelBiometricAuthSetup() async throws {
        
        guard self.userSettings?.biometricSetup == "active" else {
            throw DCError.authFailure(err: "biometrics is not active")
        }
        
        let userSettings = try await DataPC.shared.backgroundPerformSync() {
            let MO = try DataPC.shared.updateMO(entity: Settings.self,
                                                property: ["biometricSetup"],
                                                value: ["inactive"])
            return try MO.safeObject()
        }
        
        DispatchQueue.main.async {
            self.userSettings = userSettings
        }
    }
}

