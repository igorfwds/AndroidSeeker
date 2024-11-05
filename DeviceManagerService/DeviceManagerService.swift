//
//  DeviceManagerService.swift
//  DeviceManagerService
//
//  Created by ifws on 31/10/24.
//

import Foundation

/// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@objc class DeviceManagerService: NSObject, DeviceManagerServiceProtocol {
    
    var devices : [[String: Any]] = []
    
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
    
     func runADBDevices(with reply: @escaping (String) -> Void) {
        guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else {
            print("ADB binary not found")
            reply("[]") // Retorna um array JSON vazio caso o binário não seja encontrado
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
                    if !output.isEmpty {
                        let lines = output.components(separatedBy: "\n").filter { !$0.isEmpty }
                        let deviceLines = lines.dropFirst() // Ignora o cabeçalho da lista
                        var devicesArray: [[String: Any]] = []

                        for line in deviceLines {
                            let components = line.components(separatedBy: "\t")
                            if components.count > 1 {
                                let deviceDict: [String: Any] = [
                                    "id": UUID().uuidString,
                                    "name": components[0],
                                    "status": components[1],
                                    "files": [] // Lista vazia de arquivos por enquanto
                                ]
                                devicesArray.append(deviceDict)
                                
                                self.devices.append(deviceDict)
                            }
                        }

                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: devicesArray, options: [])
                            if let jsonString = String(data: jsonData, encoding: .utf8) {
                                print("JSON retornado ao cliente:", jsonString)
                                reply(jsonString)
                            } else {
                                reply("[]")
                            }
                        } catch {
                            print("Erro na serialização do JSON:", error)
                            reply("[]")
                        }
                    } else {
                        print("Comando adb devices não retornou saída.")
                        reply("[]") // Retorna JSON vazio se não houver saída
                    }
                }
            } catch {
                print("Erro ao tentar executar `adb`: \(error)")
                reply("[]") // Retorna JSON vazio em caso de erro de execução
            }
        }
    }


    
    
    
    func ping(with reply: @escaping (String) -> Void) {
        print("Service: Received ping request")
        reply("Service is connected")
    }
    
    
    
    
}
