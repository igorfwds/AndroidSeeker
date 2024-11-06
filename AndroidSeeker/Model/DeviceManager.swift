//
//  DeviceManager.swift
//  AndroidSeeker
//
//  Created by ifws on 23/09/24.
//

import Foundation
import Combine

class DeviceManager: ObservableObject {
    
    private var connectionToService: NSXPCConnection!
    
    @Published var devices: [Device] = []
    @Published var isLoading = false
    
    /// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
    
    private func conectar() async {
        self.connectionToService = NSXPCConnection(serviceName: "igor.cesar.learning.DeviceManagerService")
        self.connectionToService.remoteObjectInterface = NSXPCInterface(with: DeviceManagerServiceProtocol.self)
        
        self.connectionToService.interruptionHandler = {
            NSLog("Conexão interrompida")
            self.connectionToService = nil
        }
        self.connectionToService.invalidationHandler = {
            NSLog("Conexão invalidada")
            self.connectionToService = nil
        }
        
        self.connectionToService.resume()
    }
    
    
    public func XPCservice() async -> DeviceManagerServiceProtocol? {
        if self.connectionToService == nil {
            await self.conectar()
        }
        return self.connectionToService?.remoteObjectProxyWithErrorHandler { error in
            NSLog("Erro de conexão ao recuperar serviço: \(error.localizedDescription)")
        } as? DeviceManagerServiceProtocol
    }
    
    
    
    //    func devicesCountService() {
    //        XPCservice().runADBDevicesCount(with: { count in
    //            print("Quantidade de devices conectados: \(count)")
    //        })
    //    }
    
    func runADBDevices() async {
        guard let service = await XPCservice() else {
            print("Erro: Conexão com o serviço XPC não foi estabelecida.")
            return
        }
        
        service.runADBDevices { deviceJSONString in
            DispatchQueue.main.async {
                print("JSON bruto recebido do serviço:", deviceJSONString)  // Verificação do JSON recebido
                
                do {
                    guard let deviceData = deviceJSONString.data(using: .utf8) else {
                        print("Falha ao converter JSON string para Data")
                        return
                    }
                    
                    let devices = try JSONDecoder().decode([Device].self, from: deviceData)
                    print("Devices decodificados:", devices)
                    self.devices = devices  // Atualiza a lista de dispositivos
                    
                } catch {
                    print("Erro ao decodificar devices: \(error)")
                }
            }
        }
        self.isLoading = false
    }
    
    // Teste de conexão ao serviço com método ping
    func testPing() async {
        guard let service = await XPCservice() else {
            print("Erro: Conexão com o serviço XPC não foi estabelecida.")
            return
        }
        
        service.ping { response in
            print("Resposta do serviço XPC:", response)
        }
    }
    
    func runLsCommand(deviceName: String) async {
        guard let service = await XPCservice() else {
            print("Erro: Conexão com o serviço XPC não foi estabelecida")
            return
        }
        
        service.runLsCommand(deviceName: deviceName) { fileJSONString in
            DispatchQueue.main.async {
                print("JSON bruto do ls recebido do serviço:", fileJSONString)
                
                do {
                    guard let fileData = fileJSONString.data(using: .utf8) else {
                        print("Falha ao converter JSON string do ls para Data")
                        return
                    }
                    
                    let files = try JSONDecoder().decode([File].self, from: fileData)
                    print("Files decodificados:", files)
                    
                    if let index = self.devices.firstIndex(where: { $0.name == deviceName }) {
                        self.devices[index].files = files
                        print("Files no device \(self.devices[index].files)")
                    }
                } catch {
                    print("Erro ao decodificar files: \(error)")
                }
            }
        }
    }
    
    
    //    func runLsCommand(device: Device) {
    //        //        isLoading = true
    //        DispatchQueue.global(qos: .background).async {
    //            let task = Process()
    //            guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else { return }
    //            task.executableURL = url
    //            task.arguments = ["-s", device.name, "shell", "ls"]
    //
    //            let outputPipe = Pipe()
    //            let errorPipe = Pipe()
    //
    //            task.standardOutput = outputPipe
    //            task.standardError = errorPipe
    //
    //            do {
    //                try task.run()
    //                task.waitUntilExit()
    //
    //                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    //                let output = String(data: outputData, encoding: .utf8) ?? ""
    //
    //                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    //                let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
    //
    //
    //                DispatchQueue.main.async {
    //                    if !output.isEmpty {
    //                        let directories = output.split(separator: "\n").map(String.init)
    //
    //
    //                        let files = directories.map { dir in
    //                            File(fileName: dir, parentFile: "/", subFiles: [])
    //                        }
    //
    //
    //                        if let index = self.devices.firstIndex(where: { $0.id == device.id }) {
    //                            self.devices[index].files = files
    //                        }
    //                    }
    //
    //                    //                print("Arquivos do dispositivo \(device.name): \(files)")
    //                }
    //
    //                if !errorOutput.isEmpty {
    //                    //                print("Erros do comando:\n\(errorOutput)")
    //                }
    //
    //            } catch {
    //                print("Erro ao rodar adb: \(error)")
    //            }
    //            //            self.isLoading = false
    //        }
    //    }
    
    
    // Procurar Screenshot device
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
                //                print("O diretório Screenshots do dispositivo \(device.name) está no PATH =>  \(returnPath)")
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
    
    // Pull do screenshot
    func copyScreenshotDir(device: Device, isToggled: Bool) async {
        let paths: [String] = [
            "/storage/emulated/0/DCIM/",
            "/storage/emulated/0/Pictures/",
            "/mnt/sdcard/DCIM/"
        ]
        
        let deviceManufacturer = await runDeviceManufacturer(device: device)
        let deviceModel = await runDeviceModel(device: device)
        
        let desktopPath = "\(NSHomeDirectory())/Desktop/Devices/\(deviceManufacturer)-\(deviceModel)-\(device.name)/Screenshots"
        
        guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else { return }
        
        var screenshotDir: String = ""
        for path in paths {
            
            screenshotDir =  await runScreenshotDirSeeker(device: device, path: path)
            
            // Verifica se o diretório de screenshots foi encontrado
            if !screenshotDir.isEmpty {
                
                print("Diretório encontrado: \(screenshotDir)")
                createDirectory(at: desktopPath)
                
                let deviceModifiedAT = await dateDirectoryDevice(device: device, path: screenshotDir)
                guard let deviceDate = convertStringToDate(deviceModifiedAT) else { return print("Erro ao converter data device") }
                guard let macbookDate = getDesktopDirectoryDate(of: desktopPath) else { return print("Could not retrieve last modified date.")}
                print("Data da última modificação: \(macbookDate)")
                
                //MARK: - Comparando datas
                let isDirectoryUpdated = compareDates(deviceDate: deviceDate, macbookDate: macbookDate)
                if isDirectoryUpdated {
                    print("Não houve alteração no diretório desde a última sincronização.")
                }
                
                let desktopDirectoryFiles = getFilesFromDesktop(desktopPath: desktopPath)
                print("\nArquivos no desktop: \(desktopDirectoryFiles)")
                
                let deviceDirectoryFiles = await getFilesFromDevice(device: device, devicePath: screenshotDir)
                print("\nArquivos no device: \(deviceDirectoryFiles)")
                
                let deviceFilesDate = getDeviceFileDate(device: device, deviceDirectoryFiles: deviceDirectoryFiles, path: screenshotDir)
                let desktopFilesDate = getDesktopFileDate(desktopPath: desktopPath, desktopDirectoryFiles: desktopDirectoryFiles)
                
                
                let task = Process()
                task.executableURL = url
                
                if isToggled {
                    // Manter arquivos excluídos no desktop e adicionar os novos arquivos
                    addFilesFromDevice(deviceDirectoryFiles: deviceDirectoryFiles, desktopDirectoryFiles: desktopDirectoryFiles, device: device, desktopPath: desktopPath, screenshotDir: screenshotDir)
                    
                    modifyFilesFromDesktop(device: device, path: screenshotDir, desktopPath: desktopPath, deviceFilesDate: deviceFilesDate, desktopFilesDate: desktopFilesDate)
                    
                } else {
                    // Sincronizar e não manter arquivos excluídos no desktop
                    addFilesFromDevice(deviceDirectoryFiles: deviceDirectoryFiles, desktopDirectoryFiles: desktopDirectoryFiles, device: device, desktopPath: desktopPath, screenshotDir: screenshotDir)
                    
                    removeFilesFromDesktop(deviceDirectoryFiles: deviceDirectoryFiles, desktopDirectoryFiles: desktopDirectoryFiles, desktopPath: desktopPath)
                    
                    modifyFilesFromDesktop(device: device, path: screenshotDir, desktopPath: desktopPath, deviceFilesDate: deviceFilesDate, desktopFilesDate: desktopFilesDate)
                    
                    //                    task.arguments = ["-s", device.name, "pull", screenshotDir, desktopPath]
                    //
                    //                    let outputPipe = Pipe()
                    //                    let errorPipe = Pipe()
                    //
                    //                    task.standardOutput = outputPipe
                    //                    task.standardError = errorPipe
                    //
                    //                    do {
                    //                        try task.run()
                    //                        task.waitUntilExit()
                    //
                    //                        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                    //                        let output = String(data: outputData, encoding: .utf8) ?? ""
                    //
                    //                        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                    //                        let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
                    //                        DispatchQueue.main.async {
                    //                            if !output.isEmpty {
                    //                                print("Copiando o diretório Screenshots do dispositivo \(device.name) para a mesa... ")
                    //
                    //                            }
                    //
                    //                            if !errorOutput.isEmpty {
                    //                                print("Erros do comando PULL:\n\(errorOutput)")
                    //                            }
                    //                        }
                    //
                    //                    } catch {
                    //                        print("Erro ao rodar adb: \(error)")
                    //                    }
                }
            } else {
                print("\nDiretório não encontrado no caminho: \(path)")
            }
        }
    }
    
    // Cria o diretório no mac
    func createDirectory(at path: String) {
        let fileManager = FileManager.default
        
        do {
            
            let directoryURL = URL(fileURLWithPath: path)
            
            
            try fileManager.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            
            print("Diretório criado em: \(directoryURL.path)")
        } catch {
            print("Erro ao criar diretório: \(error.localizedDescription)")
        }
    }
    
    // Fabricante do device
    func runDeviceManufacturer(device: Device) async -> String {
        let task = Process()
        //        var vazio = ""
        guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else { return ""}
        task.executableURL = url
        task.arguments = ["-s", device.name, "shell", "getprop", "ro.product.manufacturer"]
        //        task.arguments = ["-s", device.name, "shell", "echo", vazio]
        
        
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
            
            //            print("Marca: \(output.trimmingCharacters(in: .whitespacesAndNewlines))")
            
            if output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "unknow"
            } else {
                return output.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
        } catch {
            return "Erro ao rodar adb: \(error)"
        }
    }
    
    // Modelo do device
    func runDeviceModel(device: Device) async -> String {
        let task = Process()
        guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else { return ""}
        task.executableURL = url
        task.arguments = ["-s", device.name, "shell", "getprop", "ro.product.model"]
        //        task.arguments = ["-s", device.name, "shell", "echo", ""]
        
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
            
            if output.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return "unknow"
            } else {
                return output.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
        } catch {
            return "Erro ao rodar adb: \(error)"
        }
    }
    
    func dateDirectoryDevice(device: Device, path: String) async -> String {
        let task = Process()
        guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else { return "" }
        task.executableURL = url
        task.arguments = ["-s", device.name, "shell", "stat", "-c", "%y", path, "|", "cut", "-d' '", "-f1-2", "|", "cut", "-c1-19"]
        
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
            return output.trimmingCharacters(in: .whitespacesAndNewlines)
            
        } catch {
            return "Erro ao rodar adb: \(error)"
        }
    }
    
    //    func dateDirectoryMacbook(desktopPath: String) async -> String {
    //        let task = Process()
    //        let url = "/bin/zsh"
    //        task.executableURL = URL(fileURLWithPath: url)
    //        task.arguments = ["-c", "stat -f \"%Sm\" -t \"%Y-%m-%d %H:%M:%S\" \"\(desktopPath)\""]
    //        let outputPipe = Pipe()
    //        let errorPipe = Pipe()
    //        task.standardOutput = outputPipe
    //        task.standardError = errorPipe
    //        do {
    //            try task.run()
    //            task.waitUntilExit()
    //            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
    //            let output = String(data: outputData, encoding: .utf8) ?? ""
    //            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
    //            let errorOutput = String(data: errorData, encoding: .utf8) ?? ""
    //            print("Output da data do desktop: \(output)")
    //            return output.trimmingCharacters(in: .whitespacesAndNewlines)
    //        } catch {
    //            print("Erro ao rodar adb: \(error)")
    //        }
    //        return ""
    //    }
    
    func getDesktopDirectoryDate(of filePath: String) -> Date? {
        let fileManager = FileManager.default
        
        do {
            // Recupera os atributos do arquivo
            let attributes = try fileManager.attributesOfItem(atPath: filePath)
            
            // Extrai a data de modificação
            if let modifiedDate = attributes[.modificationDate] as? Date {
                return modifiedDate
            } else {
                print("Data de modificação não encontrada.")
                return nil
            }
            
        } catch {
            print("Erro na recuperação dos atributos do arquivo: \(error.localizedDescription)")
            return nil
        }
    }
    
    //MARK: - tentativa
    func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Define o formato de entrada da string
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Garante a consistência do formato
        print("\nData formatada => \(String(describing: dateFormatter.date(from: dateString)))") //se der problema na data foi o describing
        print("Data recebida => \(dateString)")
        return dateFormatter.date(from: dateString)
    }
    
    func compareDates(deviceDate: Date, macbookDate: Date) -> Bool {
        var isDirectoryUpdated: Bool
        
        print("Data do dispositivo: \(deviceDate)")
        print("Data do MacBook: \(macbookDate)")
        
        if deviceDate > macbookDate {
            isDirectoryUpdated = false
            print("O diretório do dispositivo foi modificado mais recentemente.")
        } else {
            isDirectoryUpdated = true
            print("O diretório no MacBook foi modificado mais recentemente ou é igual.")
        }
        return isDirectoryUpdated
        
    }
    
}



