//
//  File.swift
//  DeviceManagerService
//
//  Created by lgc on 07/11/24.
//

import Foundation

@objc(File)
public class File: NSObject, Identifiable, Codable, FileProtocol {
    public var id = UUID()
    public var fileName : String
    public var parentFile : String
    public var subFiles : [File]
    
    public init(fileName: String, parentFile: String, subFiles: [File]) {
            self.fileName = fileName
            self.parentFile = parentFile
            self.subFiles = subFiles
    }
}
