//
//  Device.swift
//  DeviceManagerService
//
//  Created by lgc on 07/11/24.
//

import Foundation

@objc(Device)
public class Device: NSObject, Identifiable, Codable, DeviceProtocol {
    
    public var id: UUID
    public var name: String
    public var status: String
    public var files : [File]
    
    public init(name: String, status: String, files: [File]) {
        self.id = UUID()
        self.name = name
        self.status = status
        self.files = files
    }
    
    // MARK: - Decodable
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(UUID.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            status = try container.decode(String.self, forKey: .status)
            files = try container.decode([File].self, forKey: .files) // Certifique-se de que 'File' também é 'Decodable'
        }
        
        enum CodingKeys: String, CodingKey {
            case id, name, status, files
        }
}
