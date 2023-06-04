//
//  UserDC.swift
//  BlueZebra
//
//  Created by Harshel Bahl on 05/01/2023.
//

import Combine
import CoreData
import SocketIO

class UserDC: ObservableObject {
    
    static let shared = UserDC()
    
    @Published var userData: SUser? 
    @Published var userSettings: SSettings?
    
    /// loggedIn: controls whether user has authenticated into app
    @Published var loggedIn = false
    
    /// userOnline: state of user connection to server
    @Published var userOnline: Bool = false {
        didSet {
            print("CLIENT \(Date.now) -- UserDC.userOnline: \(userOnline)")
        }
    }
    
    enum DCError: Error {
        case failed
        case timeOut
        case serverFailure
        case disconnected
        case typecastError
    }
    
    var date: Date {
        return Date.now
    }
    
    var dateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd- HH:mm:ss"
        return dateFormatter.string(from: Date.now)
    }
    
    let stringFromDate = { (date: Date) -> String? in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd- HH:mm:ss"
        return dateFormatter.string(from: date)
    }
    
    let dateFromString =  { (dateString: String) -> Date? in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd- HH:mm:ss"
        return dateFormatter.date(from: dateString)
    }
    
    let jsonEncode = { (data: Codable) -> Data? in
        let jsonEncoder = JSONEncoder()
        //jsonEncoder.outputFormatting = .prettyPrinted
        return try? jsonEncoder.encode(data)
    }
    
    let jsonDecode = { (data: Codable) -> Data? in
        let jsonEncoder = JSONEncoder()
        //jsonEncoder.outputFormatting = .prettyPrinted
        return try? jsonEncoder.encode(data)
    }
    
    init() {
        self.addSocketHandlers()
    }
    
    func socketCallback<T>(data: [Any],
                           functionName: String,
                           failureCompletion: @escaping (Result<T, DCError>)->(),
                           completion: @escaping (Any?)->()) {
        DispatchQueue.main.async {
            do {
                if (data.first as? Bool)==true {
                    print("SERVER \(Date.now) -- UserDC.\(functionName): SUCCESS")
                    
                    if data.count > 1 {
                        completion(data[1])
                    } else {
                        completion(nil)
                    }
                } else if (data.first as? Bool)==false {
                    throw DCError.serverFailure
                } else if let result = data.first as? String, result==SocketAckStatus.noAck {
                    throw DCError.timeOut
                } else {
                    throw DCError.failed
                }
            } catch {
                print("SERVER \(Date.now) -- UserDC.\(functionName): FAILED (\(error))")
                failureCompletion(.failure(error as? DCError ?? .failed))
            }
        }
    }
    
    /// Reset User Data Controller Functions
    ///
    func resetState() {
        if self.userData != nil { self.userData = nil }
        if self.loggedIn != false { self.loggedIn = false }
        if self.userOnline != false { self.userOnline = false }
    }
}

