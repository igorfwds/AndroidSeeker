//
//  DeviceManagerService.swift
//  DeviceManagerService
//
//  Created by ifws on 31/10/24.
//

import Foundation

/// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@objc class DeviceManagerService: NSObject, DeviceManagerServiceProtocol {
    
    @Published var devices : [Device] = []
    
    func runADBDevices(with reply: @escaping (Data) -> Void) {
        guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else {
            print("ADB binary not found")
            reply(Data())
            return
        }
        
        let task = Process()
        task.executableURL = url
        task.arguments = ["devices"]
        
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = Pipe()
        
        DispatchQueue.global().async { // Executa em uma thread de background
            do {
                print("Tentando executar `task.run()` com URL:", url)
                try task.run()
                print("Executou `task.run()` com sucesso")
                task.waitUntilExit()
                
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: outputData, encoding: .utf8) ?? ""
                
                print("Saída do comando adb devices:", output)
                
                DispatchQueue.main.async {
                    var devicesArray: [Device] = []
                    
                    if !output.isEmpty {
                        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
                        let deviceLines = lines.dropFirst() // Ignora o cabeçalho da lista
                        
                        for line in deviceLines {
                            let components = line.components(separatedBy: "\t")
                            if components.count > 1 {
                                let device = Device(name: components[0], status: components[1], files: [])
                                devicesArray.append(device)
                                self.devices.append(device)
                                print("Device adicionado ao array: \(self.devices)")
                            }
                        }
                        
                    } else {
                        print("Comando adb devices não retornou saída.")
                        reply(Data()) // Retorna JSON vazio se não houver saída
                    }
                    
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: devicesArray, requiringSecureCoding: true)
                        reply(data) // Você pode devolver `devicesArray` diretamente ou, se necessário, enviar a `data`
                    } catch {
                        print("Erro ao serializar dispositivos:", error)
                        reply(Data()) // Retorna um array vazio se houver erro
                    }
                }
            } catch {
                print("Erro ao tentar executar `adb`: \(error)")
                reply(Data()) // Retorna JSON vazio em caso de erro de execução
            }
        }
    }
    //    @objc func runADBDevicesCount(with reply: @escaping (Int) -> Void) {
    //        guard let url = Bundle(for: type(of: self)).url(forResource: "adb", withExtension: nil) else {
    //            reply(999) // Código de erro se não encontrar o ADB
    //            return
    //        }
    //
    //        let task = Process()
    //        task.executableURL = url
    //        task.arguments = ["devices"]
    //
    //        let outputPipe = Pipe()
    //        let errorPipe = Pipe()
    //
    //        task.standardOutput = outputPipe
    //        task.standardError = errorPipe
    //
    //        do {
    //            try task.run()
    //            task.waitUntilExit()
    //
    //            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    //            let output = String(data: outputData, encoding: .utf8) ?? ""
    //
    //            print("Output: \(output)")
    //
    //            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    //            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
    //
    //            DispatchQueue.main.async {
    //                if !output.isEmpty {
    //                    let lines = output.split(separator: "\n").map(String.init)
    //                    print("Lines => \(lines)")
    //                    // Ignora a primeira linha e conta as linhas restantes
    //                    let deviceCount = lines.dropFirst().count
    //                    print("DeviceCount => \(deviceCount)")
    //                    print("Lines => \(lines)")
    //                    print("Lines => \(lines.count)")
    //                    reply(deviceCount) // Chama o callback com a contagem
    //
    //                } else {
    //                    reply(101) // Retorna 0 se não houver saída
    //                }
    //            }
    //
    //            if !errorOutput.isEmpty {
    //                print("Erros do comando:\n\(errorOutput)")
    //            }
    //
    //        } catch {
    //            print("Erro ao rodar adb: \(error)")
    //            reply(0)
    //        }
    //    }
    
    func ping(with reply: @escaping (String) -> Void) {
        print("Service: Received ping request")
        reply("Service is connected")
    }
    
    func runLsCommand(deviceName: String, with reply: @escaping (String) -> Void) {
        let task = Process()
        guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else { return }
        task.executableURL = url
        task.arguments = ["-s", deviceName, "shell", "ls"]
        print("DeviceName do runLs: \(deviceName)")
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        DispatchQueue.global(qos: .background).async {
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
                        var filesArray: [[String: Any]] = []
                        print("Directories: \(directories)")
                        
                        for dir in directories {
                            let fileDict: [String: Any] = [
                                "id": UUID().uuidString,
                                "fileName": dir,
                                "parentFile": "/",
                                "subFiles": []
                            ]
                            filesArray.append(fileDict)
                        }
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: filesArray, options: [])
                            if let jsonString = String(data: jsonData, encoding: .utf8) {
                                print("JSON do files retornado ao cliente:", jsonString)
                                reply(jsonString)
                            } else {
                                reply("[]")
                            }
                        } catch {
                            print("Erro na serialização do JSON do files:", error)
                            reply("[]")
                        }
                    } else {
                        print("Comando do runLsCommand não retornou saída.")
                        reply("[]")
                    }
                }
            } catch {
                print("Error ao tentar executar o ls no device: \(error)")
                reply("[]")
            }
        }
    }
}
