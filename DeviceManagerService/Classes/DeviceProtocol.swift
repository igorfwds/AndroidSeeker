//
//  DeviceProtocol.swift
//  DeviceManagerService
//
//  Created by lgc on 07/11/24.
//

import Foundation

@objc protocol DeviceProtocol {
    var name: String { get }
    var status: String { get }
    var files : [File] { get }
}
