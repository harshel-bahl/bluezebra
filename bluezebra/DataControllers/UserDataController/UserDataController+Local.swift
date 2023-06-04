//
//  UserDC+Local.swift
//  bluezebra
//
//  Created by Harshel Bahl on 19/04/2023.
//

import Foundation

extension UserDC {
    
    /// Local Read/Write Functions
    ///
    func fetchUserData(completion: ((Result<SUser, DCError>)->())? = nil) {
        DataPC.shared.fetchSMO(entity: User.self) { result in
            switch result {
            case .success(let userData):
                if let completion = completion { completion(.success(userData)) }
            case .failure(_):
                if let completion = completion { completion(.failure(.failed)) }
            }
        }
    }
    
    func fetchUserSettings(completion: ((Result<SSettings, DCError>)->())? = nil) {
        DataPC.shared.fetchSMO(entity: Settings.self) { result in
            switch result {
            case .success(let userSettings):
                if let completion = completion { completion(.success(userSettings)) }
            case .failure(_):
                if let completion = completion { completion(.failure(.failed)) }
            }
        }
    }
    
    func hardReset(completion: (Result<Void, DCError>)->()) {
        DataPC.shared.hardResetDataPC {
            self.resetState()
            ChannelDC.shared.resetState()
            MessageDC.shared.resetState()
        }
    }
}
