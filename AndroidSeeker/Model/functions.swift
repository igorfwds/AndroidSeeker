//
//  functions.swift
//  AndroidSeeker
//
//  Created by ifws on 23/09/24.
//

import Foundation

var devices: [Device] = []

func runADBDevices() -> String{
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/local/Caskroom/android-platform-tools/35.0.2/platform-tools/adb") 
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
            devices = lines.dropFirst().compactMap{line in
                let components = line.split(separator: "\t").map(String.init)
                guard components.count > 1 else{ return nil}
                return (Device(name: components[0], status: components[1], files: []))
            }
        }
        
        if !errorOutput.isEmpty {
            return("Erros do comando:\n\(errorOutput)")
        }
        
    } catch {
        return("Erro ao rodar adb: \(error)")
    }
    return "Nenhum Device detectado."
}


func runLsCommand(device: Device) -> [String] {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/local/Caskroom/android-platform-tools/35.0.2/platform-tools/adb")
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
            return directories
        }

        if !errorOutput.isEmpty {
            print("Erros do comando:\n\(errorOutput)")
        }

    } catch {
        print("Erro ao rodar adb: \(error)")
    }

    return ["Nenhum Dispositivo Encontrado"]
}
