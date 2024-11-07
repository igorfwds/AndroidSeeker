//
//  FileProtocol.swift
//  DeviceManagerService
//
//  Created by lgc on 07/11/24.
//

import Foundation

@objc protocol FileProtocol {
    var fileName: String { get }
    var parentFile: String { get }
    var subFiles : [File] { get }
}
