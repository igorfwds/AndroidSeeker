//
//  Classes.swift
//  DeviceManagerService
//
//  Created by lgc on 04/11/24.
//

import Foundation

@objc(FileService)
public class FileService: NSObject, Identifiable, Codable {
    public var id = UUID()
    public var fileName : String
    public var parentFile : String
    public var subFiles : [FileService]
    
    public init(fileName: String, parentFile: String, subFiles: [FileService]) {
            self.fileName = fileName
            self.parentFile = parentFile
            self.subFiles = subFiles
    }
}
