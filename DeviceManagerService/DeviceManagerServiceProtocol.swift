//
//  DeviceManagerServiceProtocol.swift
//  DeviceManagerService
//
//  Created by ifws on 31/10/24.
//

import Foundation

@objc protocol DeviceManagerServiceProtocol {
    
//    func runADBDevicesCount(with reply: @escaping (Int) -> Void)
    
    func runADBDevices(with reply: @escaping (Data) -> Void) 
    
    func ping(with reply: @escaping (String) -> Void)
    
    func runLsCommand(deviceName: String, deviceId: UUID, with reply: @escaping (Data) -> Void)
    
    func runScreenshotDirSeeker(deviceName: String, with reply: @escaping (String) -> Void)
    
    func runDeviceManufacturer(deviceName: String, with reply: @escaping (String) -> Void)
    
    func runDeviceModel(deviceName: String, with reply: @escaping (String) -> Void)
    
    func dateDirectoryDevice(deviceName: String, path: String, with reply: @escaping (Date) -> Void)
    
    func getFilesFromDevice(deviceName: String, devicePath: String, with reply: @escaping ([File]) -> Void)
    
    func convertStringToDate(_ dateString: String) -> Date?
}


