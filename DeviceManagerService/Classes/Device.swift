//
//  Device.swift
//  DeviceManagerService
//
//  Created by lgc on 07/11/24.
//

import Foundation

@objc(Device)
public class Device: NSObject, Identifiable, Codable, DeviceProtocol {
    public var id = UUID()
    public var name: String
    public var status: String
    public var files : [File]
    
    public init(name: String, status: String, files: [File]) {
        self.name = name
        self.status = status
        self.files = files
    }
}
