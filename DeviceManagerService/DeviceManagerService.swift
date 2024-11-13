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
                        reply(data)
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
    
    func ping(with reply: @escaping (String) -> Void) {
        print("Service: Received ping request")
        reply("Service is connected")
    }
    
    func runLsCommand(deviceName: String, deviceId: UUID, with reply: @escaping (Data) -> Void) {
        guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else {
            print("ADB binary not found")
            reply(Data())
            return
        }
        
        let task = Process()
        task.executableURL = url
        task.arguments = ["-s", deviceName, "shell", "ls"]
        
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
                
                DispatchQueue.main.async {
                    var filesArray: [File] = []
                    if !output.isEmpty {
                        let directories = output.split(separator: "\n").map(String.init)
                        print("Directories: \(directories)")
                        
                        let files = directories.map { dir in
                            File(fileName: dir, parentFile: "/", subFiles: [])
                        }
                        
                        if let index = self.devices.firstIndex(where: { $0.id == deviceId }) {
                            filesArray = files
                            self.devices[index].files = files
                        }
                    } else {
                        print("Comando do runLsCommand não retornou saída.")
                        reply(Data())
                    }
                    do {
                        let data = try NSKeyedArchiver.archivedData(withRootObject: filesArray, requiringSecureCoding: true)
                        reply(data)
                    } catch {
                        
                    }
                }
            } catch {
                print("Error ao tentar executar o ls no device: \(error)")
                reply(Data())
            }
        }
    }
    
    func runScreenshotDirSeeker(deviceName: String, with reply: @escaping (String) -> Void) {
        guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else {
            print("ADB binary not found")
            reply("")
            return
        }
        
        let paths: [String] = [
            "/storage/emulated/0/DCIM/",
            "/storage/emulated/0/Pictures/",
            "/mnt/sdcard/DCIM/"
        ]
        
        for path in paths {
            let task = Process()
            
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            
            task.executableURL = url
            task.arguments = ["-s", deviceName, "shell", "find", path, "-type", "d", "-name", "*Screenshot*"]
            
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
                    print("O diretório Screenshots do dispositivo \(deviceName) está no PATH =>  \(returnPath)")
                    reply(returnPath)
                    return
                } else {
                    print("\nDiretório não encontrado no caminho: \(path)")
                }
                
                if !errorOutput.isEmpty {
                    print("Erros do comando SEARCH:\n\(errorOutput)")
                }
                
            } catch {
                print("Erro ao rodar adb: \(error)")
                reply("")
            }
        }
    }
    
    func runDeviceManufacturer(deviceName: String, with reply: @escaping (String) -> Void) {
        guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else {
            print("ADB binary not found")
            reply("")
            return
        }
        
        let task = Process()
        task.executableURL = url
        task.arguments = ["-s", deviceName, "shell", "getprop", "ro.product.manufacturer"]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8) ?? ""
        
            if output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                reply("unknow")
            } else {
                reply(output.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
        } catch {
            print("Erro ao rodar adb: \(error)")
        }
    }
    
    func runDeviceModel(deviceName: String, with reply: @escaping (String) -> Void) {
        guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else {
            print("ADB binary not found")
            reply("")
            return
        }
        
        let task = Process()
        task.executableURL = url
        task.arguments = ["-s", deviceName, "shell", "getprop", "ro.product.model"]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8) ?? ""
        
            if output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                reply("unknow")
            } else {
                reply(output.trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
        } catch {
            print("Erro ao rodar adb: \(error)")
        }
    }
    
    func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Define o formato de entrada da string
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Garante a consistência do formato
        print("\nData formatada => \(String(describing: dateFormatter.date(from: dateString)))") //se der problema na data foi o describing
        print("Data recebida => \(dateString)")
        return dateFormatter.date(from: dateString)
    }
    
    func dateDirectoryDevice(deviceName: String, path: String, with reply: @escaping (Date) -> Void) {
        guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else {
            print("ADB binary not found")
            return
        }
        
        let task = Process()
        task.executableURL = url
        task.arguments = ["-s", deviceName, "shell", "stat", "-c", "%y", path, "|", "cut", "-d' '", "-f1-2", "|", "cut", "-c1-19"]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8) ?? ""
            
            print("Output da data device: \(output)")
            let dateDirectoryDeviceString = output.trimmingCharacters(in: .whitespacesAndNewlines)
            print("Date directory device string: \(dateDirectoryDeviceString)")
            guard let dateDirectoryDevice = convertStringToDate(dateDirectoryDeviceString) else {
                print("Erro ao converter data device")
                return
            }
            reply(dateDirectoryDevice)
            
        } catch {
            print("Erro ao rodar adb: \(error)")
        }
    }
    
    func getFilesFromDevice(deviceName: String, devicePath: String, with reply: @escaping ([File]) -> Void) {
        guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else {
            print("ADB binary not found")
            reply([])
            return
        }
        
        let task = Process()
        task.executableURL = url
        task.arguments = ["-s", deviceName, "shell", "ls", devicePath]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: outputData, encoding: .utf8) ?? ""
            
            let fileNames = output.split(separator: "\n").map(String.init)
            let filesArray = fileNames.map { File(fileName: $0, parentFile: "/", subFiles: []) }
            
            
            print("\nFilesArray: \(filesArray)")
            reply(filesArray)
        } catch {
            print("Erro ao obter arquivos do dispositivo: \(error.localizedDescription)")
            reply([])
        }
    }
    
    func getDeviceFileDate(deviceName: String, deviceDirectoryFiles: [File], path: String) async -> [String:Date] {
        
        let deviceFileNames = Set(deviceDirectoryFiles.map { $0.fileName })
        
        var deviceFilesDate: [String: Date] = [:]
    
        for file in deviceFileNames {
            
            // Pegando a data de cada arquivo
            let filePath = "\(path)/\(file)"
            
            let task = Process()
            guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else { return [:] }
            task.executableURL = url
            task.arguments = ["-s", deviceName, "shell", "stat", "-c", "%y", "'\(filePath)'", "|", "cut", "-d' '", "-f1-2", "|", "cut", "-c1-19"]
            
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
                
                print("Output da data device: \(output)")
                var dateString = output.trimmingCharacters(in: .whitespacesAndNewlines)
                print("\n Date string do device: \(dateString)")
               
                //Armazenando no dicionário
                if let fileDate = convertStringToDate(dateString) {
                    deviceFilesDate[file] = fileDate
                } else {
                    print("Erro ao converter a data para o arquivo: \(file)")
                }
                
            } catch {
                print("Erro ao rodar adb: \(error)")
            }
        }
        
        print("Dicionário do device: \(deviceFilesDate)")
        return deviceFilesDate
    }
    
    
    
}
