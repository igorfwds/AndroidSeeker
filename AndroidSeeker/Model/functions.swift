//
//  functions.swift
//  AndroidSeeker
//
//  Created by ifws on 23/09/24.
//

import Foundation
import Combine

class DeviceManager: ObservableObject {
    // Publica o array devices sempre que ele é alterado
    @Published var devices: [Device] = []
    
    // Método que roda o comando ADB para atualizar o array de devices
    func runADBDevices() {
        let task = Process()
        let taskURL = "/usr/local/Caskroom/android-platform-tools/35.0.2/platform-tools/adb"
        task.executableURL = URL(fileURLWithPath: taskURL)
        task.arguments = ["devices"]
        
        var env = ProcessInfo.processInfo.environment
        env["PATH"] = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
        task.environment = env
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()

        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8) ?? "saida"
            
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            let errorOutput = String(data: errorData, encoding: .utf8) ?? "deu erro"
            
            if !output.isEmpty {
                let lines = output.split(separator: "\n").map(String.init)
                self.devices = lines.dropFirst().compactMap { line in
                    let components = line.split(separator: "\t").map(String.init)
                    guard components.count > 1 else { return nil }
                    return Device(name: components[0], status: components[1], files: [])
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



func runLsCommand(device: Device) -> [String] {
    let task = Process()
//    let taskURL = "/opt/homebrew/bin/adb"
    let taskURL = "/usr/local/Caskroom/android-platform-tools/35.0.2/platform-tools/adb"
    task.executableURL = URL(fileURLWithPath: taskURL)
    task.arguments = ["-s", device.name, "shell", "ls"]

    var env = ProcessInfo.processInfo.environment
    env["PATH"] = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    task.environment = env

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

        if !output.isEmpty {
            let directories = output.split(separator: "\n").map(String.init)
            print(directories)
            return directories
        }
        

        if !errorOutput.isEmpty {
            print("Erros do comando:\n\(errorOutput)")
        }

    } catch {
        print("Erro ao rodar adb: \(error)")
    }

    return []
}
