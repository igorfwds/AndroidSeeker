//
//  DeviceManagerService.swift
//  DeviceManagerService
//
//  Created by ifws on 31/10/24.
//

import Foundation

/// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
class DeviceManagerService: NSObject, DeviceManagerServiceProtocol {
    
    @Published var devices: [Device] = []
    @Published var isLoading = false

    /// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
    @objc func runADBDevices() {
        
        guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else { return }
        
        let task = Process()
        task.executableURL = url
        task.arguments = ["devices"]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8) ?? ""
            
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
            
            DispatchQueue.main.async {
                if !output.isEmpty {
                    let lines = output.split(separator: "\n").map(String.init)
                    self.devices = lines.dropFirst().compactMap { line in
                        let components = line.split(separator: "\t").map(String.init)
                        guard components.count > 1 else { return nil }
                        return Device(name: components[0], status: components[1], files: [])
                    }
                    self.isLoading = false
                }
            }
            
            if !errorOutput.isEmpty {
                print("Erros do comando:\n\(errorOutput)")
            }
            
        } catch {
            print("Erro ao rodar adb: \(error)")
        }
        
    }
}
