//
//  File.swift
//  DeviceManagerService
//
//  Created by lgc on 07/11/24.
//

import Foundation

@objc(File) public class File: NSObject, Identifiable, NSSecureCoding, NSCopying {
    public static var supportsSecureCoding: Bool = true
    
    @objc public var id: UUID
    @objc public var fileName: String
    @objc public var parentFile: String
    @objc public var subFiles: [File]
    
    enum CodingKeys: String, CodingKey {
        case idKey = "id"
        case fileNameKey = "fileName"
        case parentFileKey = "parentFile"
        case subFilesKey = "subFiles"
    }
    
    @objc public init(fileName: String, parentFile: String, subFiles: [File]) {
        self.id = UUID()
        self.fileName = fileName
        self.parentFile = parentFile
        self.subFiles = subFiles
    }
    
    // MARK: - NSSecureCoding
    @objc public required convenience init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(of: NSUUID.self, forKey: CodingKeys.idKey.rawValue) as? UUID,
              let fileName = aDecoder.decodeObject(forKey: CodingKeys.fileNameKey.rawValue) as? String,
              let parentFile = aDecoder.decodeObject(forKey: CodingKeys.parentFileKey.rawValue) as? String,
              let subFiles = aDecoder.decodeObject(forKey: CodingKeys.subFilesKey.rawValue) as? [File] else {
            return nil
        }
        
        self.init(fileName: fileName, parentFile: parentFile, subFiles: subFiles)
        self.id = id
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(id as NSUUID, forKey: CodingKeys.idKey.rawValue)
        aCoder.encode(fileName, forKey: CodingKeys.fileNameKey.rawValue)
        aCoder.encode(parentFile, forKey: CodingKeys.parentFileKey.rawValue)
        aCoder.encode(subFiles, forKey: CodingKeys.subFilesKey.rawValue)
    }
    
    @objc public func copy(with zone: NSZone? = nil) -> Any {
        let copy = File(fileName: self.fileName, parentFile: self.parentFile, subFiles: self.subFiles)
        copy.id = self.id // Preserving the UUID for the copied instance
        return copy
    }
}
