//
//  File.swift
//  DeviceManagerService
//
//  Created by lgc on 07/11/24.
//

import Foundation

@objc(File)
public class File: NSObject, Identifiable, NSSecureCoding, FileProtocol {
    public static let supportsSecureCoding: Bool = true
    
    public var id: UUID
    public var fileName : String
    public var parentFile : String
    public var subFiles : [File]
    
    public init(fileName: String, parentFile: String, subFiles: [File]) {
        self.id = UUID()
        self.fileName = fileName
        self.parentFile = parentFile
        self.subFiles = subFiles
    }
    
    public func encode(with coder: NSCoder) {
        coder.encode(id.uuidString, forKey: "id")
        coder.encode(fileName, forKey: "fileName")
        coder.encode(parentFile, forKey: "parentFile")
        coder.encode(subFiles, forKey: "subFiles")
    }
    
    public required init?(coder: NSCoder) {
        guard let idString = coder.decodeObject(of: NSString.self, forKey: "id"),
              let uuid = UUID(uuidString: idString as String),
              let fileName = coder.decodeObject(of: NSString.self, forKey: "fileName") as? String,
              let parentFile = coder.decodeObject(of: NSString.self, forKey: "parentFile") as? String,
              let subFilesArray = coder.decodeObject(of: NSArray.self, forKey: "subFiles") as? [File] else {
            return nil
        }
        self.id = uuid
        self.fileName = fileName
        self.parentFile = parentFile
        self.subFiles = subFilesArray
    }
}
