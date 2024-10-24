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
    func getFilesFromDevice(device: Device, devicePath: String) async -> [File] {
        let task = Process()
        guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else { return [] }
        task.executableURL = url
        task.arguments = ["-s", device.name, "shell", "ls", devicePath] // Altere para o caminho desejado
        
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
            return fileNames.map { File(fileName: $0, parentFile: "/", subFiles: []) } // Adaptar conforme necessário
        } catch {
            print("Erro ao obter arquivos do dispositivo: \(error.localizedDescription)")
            return []
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
    
}


//    func compareFiles() -> [String: [String] ] {
//
//        var dict: [String: [String] ] = [
//            "Substituir": [],// arquivos que foram alterados no device e existem no mac
//            "Importar": [],// arquivos que apenas existem no device
//            "Deletar": [] // arquivos que existem no mac mas nao no device
//        ]
//
//
//        dict["Substituir"]?.append("lyvia.jpg")
//        dict["Substituir"]?.append("igor.jpg")
//
//        for (key, value) in dict where key == "Substituir" {
//            print( value)
//        }
//        return dict
//    }




