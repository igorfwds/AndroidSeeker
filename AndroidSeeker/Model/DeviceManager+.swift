//
//  DeviceManager+.swift
//  AndroidSeeker
//
//  Created by ifws on 24/10/24.
//

import Foundation


extension DeviceManager {
    
    //MARK: - Pegar arquivos do diretório do Mac
    func getFilesFromDesktop(desktopPath: String) -> [File] {
        //        let desktopPath = "\(NSHomeDirectory())/Desktop/Devices/"
        let fileManager = FileManager.default
        var files: [File] = []
        
        do {
            let directoryContents = try fileManager.contentsOfDirectory(atPath: desktopPath)
            for fileName in directoryContents {
                // Cria um objeto File para cada arquivo encontrado
                files.append(File(fileName: fileName, parentFile: desktopPath, subFiles: []))
            }
        } catch {
            print("Erro ao obter arquivos do Mac: \(error.localizedDescription)")
        }
        
        return files
    }
    
    //MARK: - Pergar arquivos do Device
    func getFilesFromDeviceApp(deviceName: String, devicePath: String) async -> [File] {
        guard let service = await XPCservice() else {
            print("Erro: Conexão com o serviço XPC não foi estabelecida")
            return([])
        }
        
        return await withCheckedContinuation { continuation in
            service.getFilesFromDevice(deviceName: deviceName, devicePath: devicePath) { data in
                do {
                    guard let filesArray = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, File.self, NSUUID.self, NSString.self], from: data) as? [File] else {
                        print("Erro ao desserializar")
                        continuation.resume(returning: [])
                        return
                    }
                    continuation.resume(returning: filesArray)
                } catch {
                    print("Erro ao desserializar os dados: \(error)")
                    continuation.resume(returning: [])
                }
            }
            
        }
    }
    
    //MARK: - Adicionar arquivos que não estão no desktop, mas estão no device
    func addFilesFromDevice(deviceDirectoryFiles: [File], desktopDirectoryFiles: [File], device: Device, desktopPath: String, screenshotDir: String) {
        
        let desktopFileNames = Set(desktopDirectoryFiles.map { $0.fileName })
        print("Nome dos arquivos no desktop: \(desktopFileNames)")
        
        let deviceFileNames = Set(deviceDirectoryFiles.map { $0.fileName })
        print("Nome dos arquivos no device: \(deviceFileNames)")
        
        // Arquivos no dispositivo que não estão no Mac
        let filesToAddFromDevice = deviceFileNames.subtracting(desktopFileNames)
        
        for file in filesToAddFromDevice {
            let task = Process()
            guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else { return }
            task.executableURL = url
            task.arguments = ["-s", device.name, "pull", "\(screenshotDir)/\(file)", desktopPath]
            
            do {
                try task.run()
                task.waitUntilExit()
                print("\nArquivo adicionado ao desktop: \(file)")
            } catch {
                print("Erro ao adicionar arquivo ao desktop: \(error.localizedDescription)")
            }
        }
    }
    
    func removeFilesFromDesktop(deviceDirectoryFiles: [File], desktopDirectoryFiles: [File], desktopPath: String) {
        let desktopFileNames = Set(desktopDirectoryFiles.map { $0.fileName })
        print("Nome dos arquivos no desktop: \(desktopFileNames)")
        
        let deviceFileNames = Set(deviceDirectoryFiles.map { $0.fileName })
        print("Nome dos arquivos no device: \(deviceFileNames)")
        
        // Arquivos no dispositivo que não estão no Mac
        let filesToRemoveFromDesktop = desktopFileNames.subtracting(deviceFileNames)
        
        let fileManager = FileManager.default
        
        for file in filesToRemoveFromDesktop {
            var desktopFilePath = "\(desktopPath)/\(file)"
            
            do {
                try fileManager.removeItem(atPath: desktopFilePath)
                print("Arquivo excluído do desktop: \(file)")
            } catch {
                print("Erro ao excluir arquivo do desktop: \(error.localizedDescription)")
            }
        }
        
    }
    
    func getDeviceFileDate(device: Device, deviceDirectoryFiles: [File], path: String) -> [String:Date] {
        
        let deviceFileNames = Set(deviceDirectoryFiles.map { $0.fileName })
        
        var deviceFilesDate: [String: Date] = [:]
        
        for file in deviceFileNames {
            
            // Pegando a data de cada arquivo
            let filePath = "\(path)/\(file)"
            
            let task = Process()
            guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else { return [:] }
            task.executableURL = url
            task.arguments = ["-s", device.name, "shell", "stat", "-c", "%y", "'\(filePath)'", "|", "cut", "-d' '", "-f1-2", "|", "cut", "-c1-19"]
            
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
    
    func getDesktopFileDate(desktopPath: String, desktopDirectoryFiles: [File]) -> [String:Date] {
        
        let desktopFileNames = Set(desktopDirectoryFiles.map { $0.fileName })
        
        var desktopFilesDate: [String: Date] = [:]
        
        for file in desktopFileNames {
            let fileManager = FileManager.default
            
            let filePath = "\(desktopPath)/\(file)"
            
            do {
                // Recupera os atributos do arquivo
                let attributes = try fileManager.attributesOfItem(atPath: filePath)
                
                // Extrai a data de modificação
                if let modifiedDate = attributes[.modificationDate] as? Date {
                    desktopFilesDate[file] = modifiedDate
                } else {
                    print("Data de modificação não encontrada.")
                    
                }
                
            } catch {
                print("Erro na recuperação dos atributos do arquivo: \(error.localizedDescription)")
            }
        }
        print("\nDicionário do desktop: \(desktopFilesDate)\n")
        return desktopFilesDate
    }
    
    
    func modifyFilesFromDesktop(device: Device, path: String, desktopPath: String, deviceFilesDate: [String:Date], desktopFilesDate: [String:Date]) {
        
        for (file, deviceDate) in deviceFilesDate {
            
            guard let desktopDate = desktopFilesDate[file] else { return }
            
            if deviceDate > desktopDate {
                let task = Process()
                guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else { return }
                task.executableURL = url
                task.arguments = ["-s", device.name, "pull", "\(path)/\(file)", desktopPath]
                
                do {
                    try task.run()
                    task.waitUntilExit()
                    print("\nArquivo modificado adicionado ao desktop: \(file)")
                } catch {
                    print("Erro ao adicionar arquivo modificado ao desktop: \(error.localizedDescription)")
                }
            }
        }
    }
    
}






