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
            
            print("CLIENT \(DateU.shared.logTS) -- DataPC.createDir: SUCCESS (\(intermidDirs?.joined(separator: "/") ?? "")/\(dirURL.lastPathComponent))")
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- DataPC.createDir: FAILED (\(error))")
            throw PError.fileSystemFailure
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
            
            print("CLIENT \(DateU.shared.logTS) -- DataPC.createChannelDir: SUCCESS (\(channelID))")
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- DataPC.createChannelDir: FAILED (\(error))")
            throw PError.fileSystemFailure
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
            print("CLIENT \(DateU.shared.logTS) -- DataPC.listDirContents: FAILED (\(dir))")
            throw PError.fileSystemFailure
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
            print("CLIENT \(DateU.shared.logTS) -- DataPC.getDirContents: FAILED (\(dir))")
            throw PError.fileSystemFailure
        }
    }
    
    func clearDir(dir: String,
                  intermidDirs: [String]? = nil) async throws {
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
            
            print("CLIENT \(DateU.shared.logTS) -- DataPC.clearDir: SUCCESS (removed: \(count), dirURL: \(intermidDirs?.joined(separator: "/") ?? "")/\(dirURL.lastPathComponent))")
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- DataPC.clearDir: FAILED (\(error))")
            throw PError.fileSystemFailure
        }
    }
    
    func removeDir(dir: String,
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
            try fileManager.removeItem(at: dirURL)
            print("CLIENT \(DateU.shared.logTS) -- DataPC.removeDir: SUCCESS (\(intermidDirs?.joined(separator: "/") ?? "")/\(dirURL.lastPathComponent))")
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- DataPC.removeDir: FAILED (\(error))")
            throw PError.fileSystemFailure
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
                throw PError.typecastError
            }
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- DataPC.getFileSize: FAILED (\(fileName))")
            throw error
        }
    }
    
    func storeFile(data: Data,
                   fileName: String = UUID().uuidString,
                   intermidDirs: [String]? = nil,
                   fileType: String? = nil) async throws {
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
            print("CLIENT \(DateU.shared.logTS) -- DataPC.storeFile: SUCCESS (url: \(intermidDirs?.joined(separator: "/") ?? "")/\(fileName))")
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- DataPC.storeFile: FAILED (\(error))")
            throw PError.fileStoreFailure
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
            print("CLIENT \(DateU.shared.logTS) -- DataPC.fetchFile: SUCCESS")
            return file
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- DataPC.fetchFile: FAILED (\(error))")
            throw PError.fetchFileFailure
        }
    }
    
    func removeFile(fileName: String,
                    intermidDirs: [String]? = nil) async throws {
        
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
            print("CLIENT \(DateU.shared.logTS) -- DataPC.removeFile: SUCCESS (url: \(intermidDirs?.joined(separator: "/") ?? "")/\(fileName))")
        } catch {
            print("CLIENT \(DateU.shared.logTS) -- DataPC.removeFile: FAILED (\(fileName))")
            throw PError.fileSystemFailure
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
            throw DCError.failed
        }
        
        return UIImage(cgImage: thumbnail)
    }
}
