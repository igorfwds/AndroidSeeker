//
//  DeviceManagerServiceProtocol.swift
//  DeviceManagerService
//
//  Created by ifws on 31/10/24.
//

import Foundation

/// The protocol that this service will vend as its API. This protocol will also need to be visible to the process hosting the service.
@objc protocol DeviceManagerServiceProtocol {
    
    /// Replace the API of this protocol with an API appropriate to the service you are vending.
//    func runADBDevicesCount(with reply: @escaping (Int) -> Void)
    
    func runADBDevices(with reply: @escaping (String) -> Void) 
    func ping(with reply: @escaping (String) -> Void)
    func runLsCommand(deviceName: String, with reply: @escaping (String) -> Void)
}

/*
 To use the service from an application or other process, use NSXPCConnection to establish a connection to the service by doing something like this:

     connectionToService = NSXPCConnection(serviceName: "igor.cesar.learning.DeviceManagerService")
     connectionToService.remoteObjectInterface = NSXPCInterface(with: DeviceManagerServiceProtocol.self)
     connectionToService.resume()

 Once you have a connection to the service, you can use it like this:

     if let proxy = connectionToService.remoteObjectProxy as? DeviceManagerServiceProtocol {
         proxy.performCalculation(firstNumber: 23, secondNumber: 19) { result in
             NSLog("Result of calculation is: \(result)")
         }
     }

 And, when you are finished with the service, clean up the connection like this:

     connectionToService.invalidate()
*/
