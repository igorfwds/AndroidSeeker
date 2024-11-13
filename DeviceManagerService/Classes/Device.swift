//
//  Device.swift
//  DeviceManagerService
//
//  Created by lgc on 07/11/24.
//

import Foundation

@objc(Device) public class Device: NSObject, Identifiable, NSSecureCoding, NSCopying {
    public static var supportsSecureCoding: Bool = true
    
    @objc public var id: UUID
    @objc public var name: String
    @objc public var status: String
    @objc public var files : [File]
    
    enum CodingKeys: String {
        case idKey = "id"
        case nameKey = "name"
        case statusKey = "status"
        case filesKey = "files"
    }
    
    @objc public init(name: String, status: String, files: [File]) {
        self.id = UUID()
        self.name = name
        self.status = status
        self.files = files
    }
    
    @objc public required convenience init?(coder aDecoder: NSCoder) {
        guard let id = aDecoder.decodeObject(of: NSUUID.self, forKey: CodingKeys.idKey.rawValue) as? UUID,
              let name = aDecoder.decodeObject(forKey: CodingKeys.nameKey.rawValue) as? String,
              let status = aDecoder.decodeObject(forKey: CodingKeys.statusKey.rawValue) as? String,
              let files = aDecoder.decodeObject(forKey: CodingKeys.filesKey.rawValue) as? [File] else {
            return nil }
        
        self.init(name: name, status: status, files: files)
        self.id = id
        
    }
    
    @objc public func encode(with aCoder: NSCoder) {
        aCoder.encode(id as NSUUID, forKey: CodingKeys.idKey.rawValue)
        aCoder.encode(name, forKey: CodingKeys.nameKey.rawValue)
        aCoder.encode(status, forKey: CodingKeys.statusKey.rawValue)
        aCoder.encode(files, forKey: CodingKeys.filesKey.rawValue)
    }
    
    @objc public func copy(with zone: NSZone? = nil) -> Any {
        let copy = Device(name: self.name, status: self.status, files: self.files)
        copy.id = self.id
        return copy
    }
    
}
//public class Device: NSObject, Identifiable, Codable, DeviceProtocol {
//
//    public var id: UUID
//    public var name: String
//    public var status: String
//    public var files : [File]
//
//    public init(name: String, status: String, files: [File]) {
//        self.id = UUID()
//        self.name = name
//        self.status = status
//        self.files = files
//    }
//
//    // MARK: - Decodable
//        public required init(from decoder: Decoder) throws {
//            let container = try decoder.container(keyedBy: CodingKeys.self)
//            id = try container.decode(UUID.self, forKey: .id)
//            name = try container.decode(String.self, forKey: .name)
//            status = try container.decode(String.self, forKey: .status)
//            files = try container.decode([File].self, forKey: .files) // Certifique-se de que 'File' também é 'Decodable'
//        }
//
//        enum CodingKeys: String, CodingKey {
//            case id, name, status, files
//        }
//}
