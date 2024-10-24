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
    
    
    func runADBDevices() async {
        
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
    
    
    func runLsCommand(device: Device) {
        //        isLoading = true
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
            //            self.isLoading = false
        }
    }
    
    
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
    
    // Pull do screenshot
    func copyScreenshotDir(device: Device) async {
        let paths: [String] = [
            "/storage/emulated/0/DCIM/",
            "/storage/emulated/0/Pictures/",
            "/mnt/sdcard/DCIM/"
        ]
        
        let deviceManufacturer = await runDeviceManufacturer(device: device)
        let deviceModel = await runDeviceModel(device: device)
        
        let desktopPath = "\(NSHomeDirectory())/Desktop/Devices/\(deviceManufacturer)-\(deviceModel)-\(device.name)/"
        
        guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else { return }
        
        var screenshotDir: String = ""
        for path in paths {
            screenshotDir =  await runScreenshotDirSeeker(device: device, path: path)
            
            
            // Verifica se o diretório de screenshots foi encontrado
            if !screenshotDir.isEmpty {
                
                print("Diretório encontrado: \(screenshotDir), iniciando o pull...")
                
                createDirectory(at: desktopPath)
                let task = Process()
                task.executableURL = url
                task.arguments = ["-s", device.name, "pull", screenshotDir, desktopPath]
                //                    task.arguments = ["-s", device.name, "pull", screenshotDir, "$HOME/Desktop"]
                
                let outputPipe = Pipe()
                let errorPipe = Pipe()
                
                task.standardOutput = outputPipe
                task.standardError = errorPipe
                
//                await dateDirectoryMacbook(desktopPath: desktopPath)
                var deviceModifiedAT = await dateDirectoryDevice(device: device, path: screenshotDir)
//                var deviceModifiedAT = await dateDirectoryDevice(device: device, path: screenshotDir)
                guard let deviceDate = convertStringToDate(deviceModifiedAT) else { return print("Erro ao converter data device") }
                
                guard let macbookDate = getLastModifiedDate(of: desktopPath) else { return print("Could not retrieve last modified date.")}
                    print("Last modified date: \(macbookDate)")
                
//                var macbookModifiedAT = getLastModifiedDate(of: desktopPath)
//                guard let macbookDate = convertStringToDate(macbookModifiedAT) else { return print("Erro ao converter data macbook") }
                
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
                    //MARK: - Comparando datas
                    compareDates(deviceDate: deviceDate, macbookDate: macbookDate)
                    
//                    if let deviceDate = convertStringToDate(deviceModifiedAT), let macbookDate = convertStringToDate(macbookModifiedAT) {
//                        
//                        print("Data do dispositivo: \(deviceDate)")
//                        print("Data do MacBook: \(macbookDate)")
//                        
//                        
//                        
//                        if deviceDate > macbookDate {
//                            print("O diretório do dispositivo foi modificado mais recentemente.")
//                        } else {
//                            print("O diretório no MacBook foi modificado mais recentemente ou é igual.")
//                        }
//                    } else {
//                        print("Erro ao converter as datas.")
//                    }
                    //MARK: - fim da comparação
                } catch {
                    print("Erro ao rodar adb: \(error)")
                }
            } else {
                print("Diretório não encontrado no caminho: \(path)")
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
            
            print("Marca: \(output.trimmingCharacters(in: .whitespacesAndNewlines))")
            
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
    
    func getLastModifiedDate(of filePath: String) -> Date? {
        let fileManager = FileManager.default

        do {
            // Retrieve the file attributes
            let attributes = try fileManager.attributesOfItem(atPath: filePath)

            // Extract the modification date
            if let modifiedDate = attributes[.modificationDate] as? Date {
                return modifiedDate
            } else {
                print("Modification date attribute not found.")
                return nil
            }

        } catch {
            // Handle any errors that occur
            print("Error retrieving file attributes: \(error.localizedDescription)")
            return nil
        }
    }
    
    //MARK: - tentativa
    func convertStringToDate(_ dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Define o formato de entrada da string
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Garante a consistência do formato
        print("TESTE DA CONVERSÃO \n => \(dateFormatter.date(from: dateString))")
        print("Data recebida =>\(dateString)")
        return dateFormatter.date(from: dateString)
    }
    
    func compareDates(deviceDate: Date, macbookDate: Date) {
        //MARK: - Comparando datas
            
        print("Data do dispositivo: \(deviceDate)")
        print("Data do MacBook: \(macbookDate)")
    
        if deviceDate > macbookDate {
            print("O diretório do dispositivo foi modificado mais recentemente.")
        } else {
            print("O diretório no MacBook foi modificado mais recentemente ou é igual.")
        }

        //MARK: - fim da comparação
    }
    
}



