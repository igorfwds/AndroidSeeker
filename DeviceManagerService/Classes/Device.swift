//
//  Device.swift
//  DeviceManagerService
//
//  Created by lgc on 07/11/24.
//

import Foundation

@objc(Device)
public class Device: NSObject, Identifiable, NSSecureCoding, DeviceProtocol {
    public static let supportsSecureCoding: Bool = true
    
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
    
    public func encode(with coder: NSCoder) {
        coder.encode(id.uuidString, forKey: "id")
        coder.encode(name, forKey: "name")
        coder.encode(status, forKey: "status")
        coder.encode(files, forKey: "files")
    }
    
    public required init?(coder: NSCoder) {
        guard let idString = coder.decodeObject(of: NSString.self, forKey: "id"),
              let uuid = UUID(uuidString: idString as String),
              let name = coder.decodeObject(of: NSString.self, forKey: "name") as? String,
              let status = coder.decodeObject(of: NSString.self, forKey: "status") as? String,
              let filesArray = coder.decodeObject(ofClasses: [NSArray.self, File.self], forKey: "files") as? [File] else {
            return nil
        }
        self.id = uuid
        self.name = name
        self.status = status
        self.files = filesArray
    }
}
