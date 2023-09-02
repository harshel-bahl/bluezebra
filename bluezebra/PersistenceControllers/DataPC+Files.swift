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
        do {
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
            
            try fileManager.createDirectory(at: dirURL,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
            
            log.debug(message: "created directory", function: "DataPC.createDir", info: "dir: \(dir)")
        } catch {
            log.error(message: "failed to create directory", function: "DataPC.createDir", error: error, info: "dir: \(dir)")
            throw error
        }
    }
    
    func createChannelDir(channelID: String,
                          dirs: [String] = ["images", "files"]) async throws {
        do {
            let fileManager = FileManager.default
            
            let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            
            let topDirURL = documentsDirectory.appendingPathComponent(channelID)
            
            try fileManager.createDirectory(at: topDirURL,
                                            withIntermediateDirectories: true)
            
            for dir in dirs {
                let dirURL = topDirURL.appendingPathComponent(dir)
                
                try fileManager.createDirectory(at: dirURL,
                                                withIntermediateDirectories: true)
            }
            
            
            log.debug(message: "created channel directories", function: "DataPC.createChannelDir", info: "channelID: \(channelID)")
        } catch {
            log.error(message: "failed to create channel directory", function: "DataPC.createChannelDir", error: error, info: "channelID: \(channelID)")
            throw error
        }
    }
    
    func listDirContents(dir: String,
                         intermidDirs: [String]? = nil,
                         attributes: [FileAttributeKey]? = nil) async throws {
        do {
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
            log.error(message: "failed to list directory contents", function: "DataPC.listDirContents", error: error, info: "dir: \(dir)")
            throw error
        }
    }
    
    func getDirContents(dir: String,
                        intermidDirs: [String]? = nil) throws -> [String] {
        do {
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
            
            let contents = try fileManager.contentsOfDirectory(at: dirURL,
                                                               includingPropertiesForKeys: nil,
                                                               options: [])
            var files = [String]()
            
            for fileURL in contents {
                files.append(fileURL.lastPathComponent)
            }
            
            log.debug(message: "successfully fetched directory contents", function: "DataPC.getDirContents", info: "dir: \(intermidDirs?.joined(separator: "/") ?? "")/\(dirURL.lastPathComponent)")
            
            return files
        } catch {
            log.error(message: "failed to get directory contents", function: "DataPC.getDirContents", error: error, info: "dir: \(dir)")
            throw error
        }
    }
    
    func clearDir(dir: String,
                  intermidDirs: [String]? = nil) async throws {
        do {
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
            
            let contents = try fileManager.contentsOfDirectory(at: dirURL,
                                                               includingPropertiesForKeys: nil,
                                                               options: [])
            var count = 0
            
            for fileURL in contents {
                try fileManager.removeItem(at: fileURL)
                count += 1
            }
            
            log.debug(message: "cleared directory", function: "DataPC.clearDir", info: "dir: \(intermidDirs?.joined(separator: "/") ?? "")/\(dirURL.lastPathComponent)")
        } catch {
            log.error(message: "failed to clear directory", function: "DataPC.clearDir", info: "dir: \(dir)")
            throw error
        }
    }
    
    func removeDir(dir: String,
                   intermidDirs: [String]? = nil) async throws {
        do {
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
            
            try fileManager.removeItem(at: dirURL)
            
            log.debug(message: "removed directory", function: "DataPC.removeDir", info: "dir: \(intermidDirs?.joined(separator: "/") ?? "")/\(dirURL.lastPathComponent)")
        } catch {
            log.error(message: "removed directory", function: "DataPC.removeDir", error: error, info: "dir: \(dir)")
            throw error
        }
    }
    
    func getFileSize(fileName: String,
                     intermidDirs: [String]? = nil) throws -> Int64 {
        do {
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
            
            let fileAttributes = try fileManager.attributesOfItem(atPath: fileURL.path)
            
            if let fileSize = fileAttributes[.size] as? Int64 {
                log.debug(message: "fetched file size", function: "DataPC.getFileSize", info: "fileURL: \(intermidDirs?.joined(separator: "/") ?? "")/\(fileURL.lastPathComponent)")
                return fileSize
            } else {
                throw PError.typecastError(err: "fileAttributes failed to convert to Int64")
            }
        } catch {
            log.error(message: "failed to fetch file size", function: "DataPC.getFileSize", error: error, info: "filename: \(fileName)")
            throw error
        }
    }
    
    func storeFile(data: Data,
                   fileName: String = UUID().uuidString,
                   intermidDirs: [String]? = nil,
                   fileType: String? = nil) async throws {
        do {
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
            
            try data.write(to: fileURL)
            
            log.debug(message: "stored file", function: "DataPC.storeFile", info: "fileURL: \(intermidDirs?.joined(separator: "/") ?? "")/\(fileURL.lastPathComponent)")
        } catch {
            log.error(message: "failed to store file", function: "DataPC.storeFile", error: error, info: "filename: \(fileName)")
            throw error
        }
    }
    
    func fetchFile(fileName: String,
                   intermidDirs: [String]? = nil) async throws -> Data {
        do {
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
            
            let file = try Data(contentsOf: fileURL)
            
            log.debug(message: "fetched file", function: "DataPC.fetchFile", info: "fileURL: \(intermidDirs?.joined(separator: "/") ?? "")/\(fileURL.lastPathComponent)")
            
            return file
        } catch {
            log.error(message: "failed to fetch file", function: "DataPC.fetchFile", error: error, info: "filename: \(fileName)")
            throw error
        }
    }
    
    func removeFile(fileName: String,
                    intermidDirs: [String]? = nil) async throws {
        do {
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
            
            try fileManager.removeItem(at: fileURL)
            
            log.debug(message: "removed file", function: "DataPC.removeFile", info: "fileURL: \(intermidDirs?.joined(separator: "/") ?? "")/\(fileURL.lastPathComponent)")
        } catch {
            log.error(message: "failed to remove file", function: "DataPC.removeFile", error: error, info: "filename: \(fileName)")
            throw error
        }
    }
    
    func scaledImage(imageName: String? = nil,
                     intermidDirs: [String]? = nil,
                     from url: URL? = nil,
                     maxDimension: CGFloat) async throws -> UIImage {
        do {
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
                throw PError.imageDataFailure(err: "failed to create thumbnail from image data")
            }
            
            log.debug(message: "fetched image thumbnail", function: "DataPC.scaledImage", info: "imageURL: \(intermidDirs?.joined(separator: "/") ?? "")/\(imageURL.lastPathComponent)")
            
            return UIImage(cgImage: thumbnail)
        } catch {
            log.error(message: "failed to fetch image thumbnail", function: "DataPC.scaledImage", error: error, info: "imageName: \(imageName ?? ""), url: \(String(describing: url))")
            throw error
        }
    }
}
