//
//  DeviceManagerService.swift
//  DeviceManagerService
//
//  Created by ifws on 31/10/24.
//

import Foundation

/// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
class DeviceManagerService: NSObject, DeviceManagerServiceProtocol {
    
    @objc func runADBDevicesCount(with reply: @escaping (Int) -> Void) {
        guard let url = Bundle(for: type(of: self)).url(forResource: "adb", withExtension: nil) else {
            reply(999) // Código de erro se não encontrar o ADB
            return
        }
        
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
            
            print("Output: \(output)")
            
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
            
            DispatchQueue.main.async {
                if !output.isEmpty {
                    let lines = output.split(separator: "\n").map(String.init)
                    print("Lines => \(lines)")
                    // Ignora a primeira linha e conta as linhas restantes
                    let deviceCount = lines.dropFirst().count
                    print("DeviceCount => \(deviceCount)")
                    print("Lines => \(lines)")
                    print("Lines => \(lines.count)")
                    reply(deviceCount) // Chama o callback com a contagem
                    
                } else {
                    reply(101) // Retorna 0 se não houver saída
                }
            }
            
            if !errorOutput.isEmpty {
                print("Erros do comando:\n\(errorOutput)")
            }
            
        } catch {
            print("Erro ao rodar adb: \(error)")
            reply(0)
        }
    }
    
    
    
}
