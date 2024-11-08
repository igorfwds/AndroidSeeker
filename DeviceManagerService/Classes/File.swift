//
//  File.swift
//  DeviceManagerService
//
//  Created by lgc on 07/11/24.
//

import Foundation

@objc(File)
public class File: NSObject, Identifiable, Codable, FileProtocol {
    
    public var id: UUID
    public var fileName: String
    public var parentFile: String
    public var subFiles: [File]
    
    public init(fileName: String, parentFile: String, subFiles: [File]) {
        self.id = UUID()
        self.fileName = fileName
        self.parentFile = parentFile
        self.subFiles = subFiles
    }
    
    // MARK: - Decodable
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        fileName = try container.decode(String.self, forKey: .fileName)
        parentFile = try container.decode(String.self, forKey: .parentFile)
        subFiles = try container.decode([File].self, forKey: .subFiles)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, fileName, parentFile, subFiles
    }
}

