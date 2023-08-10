//
//  DataPC+Files.swift
//  bluezebra
//
//  Created by Harshel Bahl on 21/07/2023.
//

import Foundation
import SwiftUI
import ImageIO

extension DataPC {
    
    func checkDir(dir: String,
                  intermidDirs: [String]? = nil) -> Bool {
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
        
        if fileManager.fileExists(atPath: dirURL.path) {
            return true
        } else {
            return false
        }
    }
    
    func createDir(dir: String,
                   intermidDirs: [String]? = nil) async throws {
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
        } catch {
            throw PError.fileSystemFailure(func: "createDir", err: error.localizedDescription)
        }
    }
    
    func createChannelDir(channelID: String,
                          dirs: [String] = ["images", "files"]) async throws {
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
        } catch {
            throw PError.fileSystemFailure(func: "createChannelDir", err: error.localizedDescription)
        }
    }
    
    func listDirContents(dir: String,
                         intermidDirs: [String]? = nil,
                         attributes: [FileAttributeKey]? = nil) async throws {
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
            let contents = try fileManager.contentsOfDirectory(at: dirURL,
                                                               includingPropertiesForKeys: nil,
                                                               options: [])
            
            for fileURL in contents {
                if let attributes = attributes {
                    let fileAttributes = try fileManager.attributesOfItem(atPath: fileURL.path)
                    var specAttributes = [String]()
                    
                    for attribute in attributes {
                        if let fileAttribute = fileAttributes[attribute] as? String {
                            specAttributes.append(fileAttribute)
                        }
                    }
                    print(fileURL.lastPathComponent, ": ", specAttributes)
                } else {
                    print(fileURL.lastPathComponent)
                }
            }
        } catch {
            throw PError.fileSystemFailure(func: "listDirContents", err: error.localizedDescription)
        }
    }
    
    func getDirContents(dir: String,
                        intermidDirs: [String]? = nil) throws -> [String] {
        
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
            let contents = try fileManager.contentsOfDirectory(at: dirURL,
                                                               includingPropertiesForKeys: nil,
                                                               options: [])
            var files = [String]()
            
            for fileURL in contents {
                files.append(fileURL.lastPathComponent)
            }
            
            return files
        } catch {
            throw PError.fileSystemFailure(func: "getDirContents", err: error.localizedDescription)
        }
    }
    
    func clearDir(dir: String,
                  intermidDirs: [String]? = nil,
                  showLogs: Bool = false) async throws {
        let fileManager = FileManager.default
        
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        var dirURL = documentsDirectory
        
        if let intermidDirs = intermidDirs {
            for intermidDir in intermidDirs {
                dirURL = dirURL.appendingPathComponent(intermidDir)
            }
            
            dirURL = dirURL.appendingPathComponent(dir)
        } else if dir != "" {
            dirURL = dirURL.appendingPathComponent(dir)
        }
        
        do {
            let contents = try fileManager.contentsOfDirectory(at: dirURL,
                                                               includingPropertiesForKeys: nil,
                                                               options: [])
            var count = 0
            
            for fileURL in contents {
                try fileManager.removeItem(at: fileURL)
                count += 1
            }
            
            if showLogs {
                print("SUCCESS \(DateU.shared.logTS) -- DataPC.clearDir removed: \(count), dirURL: \(intermidDirs?.joined(separator: "/") ?? "")/\(dirURL.lastPathComponent)")
            }
        } catch {
            throw PError.fileSystemFailure(func: "clearDir", err: error.localizedDescription)
        }
    }
    
    func removeDir(dir: String,
                   intermidDirs: [String]? = nil,
                   showLogs: Bool = false) async throws {
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
            try fileManager.removeItem(at: dirURL)
            
            if showLogs { print("SUCCESS \(DateU.shared.logTS) -- DataPC.removeDir dir: \(intermidDirs?.joined(separator: "/") ?? "")/\(dirURL.lastPathComponent)") }
        } catch {
            throw PError.fileSystemFailure(func: "removeDir", err: error.localizedDescription)
        }
    }
    
    func getFileSize(fileName: String,
                     intermidDirs: [String]? = nil) throws -> Int64 {
        
        let fileManager = FileManager.default
        
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        var fileURL = documentsDirectory
        
        if let intermidDirs = intermidDirs {
            for intermidDir in intermidDirs {
                fileURL = fileURL.appendingPathComponent(intermidDir)
            }
            
            fileURL = fileURL.appendingPathComponent(fileName)
        } else {
            fileURL = fileURL.appendingPathComponent(fileName)
        }
        
        do {
            let fileAttributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            
            if let fileSize = fileAttributes[.size] as? Int64 {
                return fileSize
            } else {
                throw PError.typecastError(func: "getFileSize", err: "fileAttributes failed to convert to Int64")
            }
        } catch {
            if let error = error as? PError {
                throw error
            } else {
                throw PError.fileSystemFailure(func: "getFileSize", err: error.localizedDescription)
            }
        }
    }
    
    func storeFile(data: Data,
                   fileName: String = UUID().uuidString,
                   intermidDirs: [String]? = nil,
                   fileType: String? = nil,
                   showLogs: Bool = false) async throws {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        var fileURL = documentsDir
        
        if let intermidDirs = intermidDirs {
            for intermidDir in intermidDirs {
                fileURL = fileURL.appendingPathComponent(intermidDir)
            }
            
            fileURL = fileURL.appendingPathComponent(fileName + (fileType ?? ""))
        } else {
            fileURL = fileURL.appendingPathComponent(fileName + (fileType ?? ""))
        }
        
        do {
            try data.write(to: fileURL)
            
            if showLogs {
                print("SUCCESS \(DateU.shared.logTS) -- DataPC.storeFile url: \(intermidDirs?.joined(separator: "/") ?? "")/\(fileName)")
            }
        } catch {
            throw PError.fileSystemFailure(func: "storeFile", err: error.localizedDescription)
        }
    }
    
    func fetchFile(fileName: String,
                   intermidDirs: [String]? = nil) async throws -> Data {
        let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        var fileURL = documentsDir
        
        if let intermidDirs = intermidDirs {
            for intermidDir in intermidDirs {
                fileURL = fileURL.appendingPathComponent(intermidDir)
            }
            
            fileURL = fileURL.appendingPathComponent(fileName)
        } else {
            fileURL = fileURL.appendingPathComponent(fileName)
        }
        
        do {
            let file = try Data(contentsOf: fileURL)
            return file
        } catch {
            throw PError.fileSystemFailure(func: "fetchFile", err: error.localizedDescription)
        }
    }
    
    func removeFile(fileName: String,
                    intermidDirs: [String]? = nil,
                    showLogs: Bool = false) async throws {
        
        let fileManager = FileManager.default
        
        let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        var fileURL = documentsDir
        
        if let intermidDirs = intermidDirs {
            for intermidDir in intermidDirs {
                fileURL = fileURL.appendingPathComponent(intermidDir)
            }
            
            fileURL = fileURL.appendingPathComponent(fileName)
        } else {
            fileURL = fileURL.appendingPathComponent(fileName)
        }
        
        do {
            try fileManager.removeItem(at: fileURL)
            
            if showLogs {
                print("SUCCESS \(DateU.shared.logTS) -- DataPC.removeFile url: \(intermidDirs?.joined(separator: "/") ?? "")/\(fileName)")
            }
        } catch {
            throw PError.fileSystemFailure(func: "removeFile", err: error.localizedDescription)
        }
    }
    
    func scaledImage(imageName: String? = nil,
                     intermidDirs: [String]? = nil,
                     from url: URL? = nil,
                     maxDimension: CGFloat) async throws -> UIImage {
        
        var imageURL: URL
        
        if let url = url {
            imageURL = url
        } else {
            let fileManager = FileManager.default
            
            let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            imageURL = documentsDir
            
            if let intermidDirs = intermidDirs {
                for intermidDir in intermidDirs {
                    imageURL = imageURL.appendingPathComponent(intermidDir)
                }
                
                imageURL = imageURL.appendingPathComponent(imageName!)
            } else {
                imageURL = imageURL.appendingPathComponent(imageName!)
            }
        }
        
        let options: [NSString: Any] = [
            kCGImageSourceShouldCache: false,
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimension,
            kCGImageSourceCreateThumbnailWithTransform: true
        ]
        
        guard let imageSource = CGImageSourceCreateWithURL(imageURL as CFURL, nil),
              let thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            throw PError.imageDataFailure(func: "scaledImage", err: "failed to create thumbnail for \(imageURL.lastPathComponent)")
        }
        
        return UIImage(cgImage: thumbnail)
    }
}
