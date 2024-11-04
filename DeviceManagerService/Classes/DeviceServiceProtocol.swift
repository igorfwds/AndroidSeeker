//
//  DeviceServiceProtocol.swift
//  DeviceManagerService
//
//  Created by lgc on 04/11/24.
//

import Foundation

@objc protocol DeviceProtocol {
    var name: String { get }
    var status: String { get }
    var files : [FileService] { get }
}
