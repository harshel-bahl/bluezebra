//
//  DataPC+Files.swift
//  bluezebra
//
//  Created by Harshel Bahl on 21/07/2023.
//

import Foundation
import SwiftUI

extension DataPC {
    
    func checkDir(dir: String) -> Bool {
        let fileManager = FileManager.default
        
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let directoryURL = documentsDirectory.appendingPathComponent(dir)
        
        if fileManager.fileExists(atPath: directoryURL.path) {
            return true
        } else {
            return false
        }
    }
    
    func createDir(dir: String,
                   intermidDirs: [String]? = nil) throws {
        let fileManager = FileManager.default
        
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        var dirURL = documentsDirectory
        
        if let intermidDirs = intermidDirs {
            for intermidDir in intermidDirs {
                dirURL = dirURL.appendingPathComponent(intermidDir)
            }
            
            dirURL = dirURL.appendingPathComponent(dir)
        } else {
            dirURL = dirURL.appendingPathComponent(dir)
        }
        
        do {
            try fileManager.createDirectory(at: dirURL,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
            
            print("CLIENT \(DateU.shared.logTS) -- DataPC.createDir: SUCCESS (\(dir))")
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- DataPC.createDir: FAILED (\(error))")
            throw PError.fileSystemFailure
        }
    }
    
    func createChannelDir(channelID: String,
                          dirs: [String] = ["images", "files"]) throws {
        let fileManager = FileManager.default
        
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let topDirURL = documentsDirectory.appendingPathComponent(channelID)
        
        do {
            try fileManager.createDirectory(at: topDirURL,
                                        withIntermediateDirectories: true)
            
            for dir in dirs {
                let dirURL = topDirURL.appendingPathComponent(dir)
                
                try fileManager.createDirectory(at: dirURL,
                                                withIntermediateDirectories: true)
            }
            
            print("CLIENT \(DateU.shared.logTS) -- DataPC.createChannelDir: SUCCESS (\(channelID))")
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- DataPC.createChannelDir: FAILED (\(error))")
            throw PError.fileSystemFailure
        }
        
    }
    
    func storeFile(data: Data,
                   name: String = UUID().uuidString,
                   dir: String,
                   fileType: String? = nil) async throws {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dirPath = path.appendingPathComponent(dir)
        let fileURL = dirPath.appendingPathComponent(name + (fileType ?? ""))
        
        do {
            try data.write(to: fileURL)
            print("CLIENT \(DateU.shared.logTS) -- DataPC.storeFile: SUCCESS")
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- DataPC.storeFile: FAILED (\(error))")
            throw PError.fileStoreFailure
        }
    }
    
    func fetchFile(fileName: String,
                   dir: String? = nil) async throws -> Data {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        var fileURL: URL
        
        if let dir = dir {
            fileURL = documentsDirectory.appendingPathComponent(dir).appending(path: fileName)
        } else {
            fileURL = documentsDirectory.appendingPathComponent(fileName)
        }
        
        do {
            let file = try Data(contentsOf: fileURL)
            print("CLIENT \(DateU.shared.logTS) -- DataPC.fetchFile: SUCCESS")
            return file
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- DataPC.fetchFile: FAILED (\(error))")
            throw PError.fetchFileFailure
        }
    }
}
