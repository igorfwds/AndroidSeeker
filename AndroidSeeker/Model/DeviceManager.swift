//
//  DeviceManager.swift
//  AndroidSeeker
//
//  Created by ifws on 23/09/24.
//

import Foundation
import Combine

class DeviceManager: ObservableObject {
    
    @Published var devices: [Device] = []
    @Published var isLoading = false
    
    
    func runADBDevices() {
        
        DispatchQueue.global(qos: .background).async {
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
                    }
                    self.isLoading = false
                }
                
                if !errorOutput.isEmpty {
                    print("Erros do comando:\n\(errorOutput)")
                }
                
            } catch {
                print("Erro ao rodar adb: \(error)")
            }
        }
    }
    
    
    func runLsCommand(device: Device) {
        isLoading = true
        DispatchQueue.global(qos: .background).async {
            let task = Process()
            guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else { return }
            task.executableURL = url
            task.arguments = ["-s", device.name, "shell", "ls"]
            
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
                        let directories = output.split(separator: "\n").map(String.init)
                        
                        
                        let files = directories.map { dir in
                            File(fileName: dir, parentFile: "/", subFiles: [])
                        }
                        
                        
                        if let index = self.devices.firstIndex(where: { $0.id == device.id }) {
                            self.devices[index].files = files
                        }
                    }
                    
                    //                print("Arquivos do dispositivo \(device.name): \(files)")
                }
                
                if !errorOutput.isEmpty {
                    //                print("Erros do comando:\n\(errorOutput)")
                }
                
            } catch {
                print("Erro ao rodar adb: \(error)")
            }
            self.isLoading = false
        }
    }
    
    func runScreenshotDirSeeker(device: Device, path: String) async -> String {
        let task = Process()
        guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else { return "ADB não encontrado" }
        task.executableURL = url
        task.arguments = ["-s", device.name, "shell", "find", path, "-type", "d", "-name", "*Screenshot*"]
        
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
                let returnPath = output.trimmingCharacters(in: .whitespacesAndNewlines)
                print("O diretório Screenshots do dispositivo \(device.name) está no PATH =>  \(returnPath)")
                return returnPath
            }
            
            if !errorOutput.isEmpty {
                print("Erros do comando SEARCH:\n\(errorOutput)")
            }
            
        } catch {
            print("Erro ao rodar adb: \(error)")
        }
        return ""
    }
    
    func copyScreenshotDir(device: Device) async {
        let paths: [String] = [
            "/storage/emulated/0/DCIM/",
            "/storage/emulated/0/Pictures/",
            "/mnt/sdcard/DCIM/"
        ]
        
        guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else { return }
        
        var screenshotDir: String = ""
        for path in paths {
            screenshotDir =  await runScreenshotDirSeeker(device: device, path: path)
            
            // Verifica se o diretório de screenshots foi encontrado
            if !screenshotDir.isEmpty {
                print("Diretório encontrado: \(screenshotDir), iniciando o pull...")
                
                let task = Process()
                task.executableURL = url
                let desktopPath = "\(NSHomeDirectory())/Desktop"
                task.arguments = ["-s", device.name, "pull", screenshotDir, desktopPath]
                //                    task.arguments = ["-s", device.name, "pull", screenshotDir, "$HOME/Desktop"]
                
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
                            print("Copiando o diretório Screenshots do dispositivo \(device.name) para a mesa... ")
                            
                        }
                        
                        if !errorOutput.isEmpty {
                            print("Erros do comando PULL:\n\(errorOutput)")
                        }
                    }
                    
                } catch {
                    print("Erro ao rodar adb: \(error)")
                }
            } else {
                print("Diretório não encontrado no caminho: \(path)")
            }
        }
    }
}


