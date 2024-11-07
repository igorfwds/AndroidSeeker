//
//  DeviceService.swift
//  DeviceManagerService
//
//  Created by lgc on 04/11/24.
//

import Foundation

@objc(DeviceService)
public class DeviceService: NSObject, Identifiable, Codable, DeviceProtocol {
    public var id = UUID()
    public var name: String
    public var status: String
    public var files : [FileService]
    
    public init(name: String, status: String, files: [FileService]) {
        self.name = name
        self.status = status
        self.files = files
    }
}

