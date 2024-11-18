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
    
    func runADBDevices() async {
        guard let service = await XPCservice() else {
            print("Erro: Conexão com o serviço XPC não foi estabelecida.")
            return
        }
        
        
        service.runADBDevices { data in
            print("Conteúdo recebido do serviço:", data)
            do {
                guard let devicesArray = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, Device.self, NSUUID.self, NSString.self], from: data) as? [Device] else {
                    print("Erro ao desserializar")
                    return
                }
                print("\nDecoded Devices \(devicesArray)")
                DispatchQueue.main.async {
                    self.devices = devicesArray
                    self.isLoading = false
                }
                
            } catch {
                print("Erro ao desserializar os dados: \(error)")
                DispatchQueue.main.async {
                    self.devices = []
                    self.isLoading = false
                }
            }
            
            print("Array de devices do app: \(self.devices)")
        }
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
    
    func runLsCommand(deviceName: String, deviceId: UUID) async {
        self.isLoading = true
        guard let service = await XPCservice() else {
            print("Erro: Conexão com o serviço XPC não foi estabelecida")
            return
        }
        
        service.runLsCommand(deviceName: deviceName, deviceId: deviceId) { data in
            
            DispatchQueue.main.async {
                print("Conteúdo recebido do ls do serviço:", data)
                
                do {
                    guard let filesArray = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSArray.self, File.self, NSUUID.self, NSString.self], from: data) as? [File] else {
                        print("Erro ao desserializar")
                        return
                    }
                    print("\nDecoded Files: \(filesArray)")
                    
                    DispatchQueue.main.async {
                        if let index = self.devices.firstIndex(where: { $0.id == deviceId }) {
                            self.devices[index].files = filesArray
                            self.isLoading = false
                            
                        }
                    }
                    
                    
                } catch {
                    print("Erro ao decodificar files: \(error)")
                }
            }
        }
    }
    
    
    // Procurar Screenshot device
    func runScreenshotDirSeekerApp(deviceName: String) async -> String {
        guard let service = await XPCservice() else {
            print("Erro: Conexão com o serviço XPC não foi estabelecida")
            return ""
        }
        
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                service.runScreenshotDirSeeker(deviceName: deviceName) { path in
                    continuation.resume(returning: path)
                }
            }
        }
    }
    
    // Pull do screenshot
    func copyScreenshotDir(device: Device, isToggled: Bool) async {
        
        let deviceManufacturer = await runDeviceManufacturerApp(deviceName: device.name)
        let deviceModel = await runDeviceModelApp(deviceName: device.name)
        
        let desktopPath = "\(NSHomeDirectory())/Desktop/Devices/\(deviceManufacturer)-\(deviceModel)-\(device.name)/Screenshots"
        
        guard let url = Bundle.main.url(forResource: "adb", withExtension: nil) else { return }
        
        var screenshotDir: String = ""
        
        screenshotDir =  await runScreenshotDirSeekerApp(deviceName: device.name)
        
        // Verifica se o diretório de screenshots foi encontrado
        if !screenshotDir.isEmpty {
            
            print("Diretório encontrado: \(screenshotDir)")
            createDirectory(at: desktopPath)
            
            let deviceDate = await getDeviceDirectoryDateApp(deviceName: device.name, path: screenshotDir)
            guard let macbookDate = await getDesktopDirectoryDate(of: desktopPath) else { return print("Não foi possível obter a última data de modificação.")}
            print("Data da última modificação: \(macbookDate)")
            
            //MARK: - Comparando datas
            let isDirectoryUpdated = compareDates(deviceDate: deviceDate, macbookDate: macbookDate)
            if isDirectoryUpdated {
                print("Não houve alteração no diretório desde a última sincronização.")
            }
            
            let desktopDirectoryFiles = await getFilesFromDesktop(desktopPath: desktopPath)
            print("\nArquivos no desktop: \(desktopDirectoryFiles)")
            
            let deviceDirectoryFiles = await getFilesFromDeviceApp(deviceName: device.name, devicePath: screenshotDir)
            print("\nArquivos no device: \(deviceDirectoryFiles)")
            
            let deviceFilesDate = await getDeviceFileDateApp(deviceName: device.name, deviceDirectoryFiles: deviceDirectoryFiles, path: screenshotDir)
            let desktopFilesDate = await getDesktopFileDate(desktopPath: desktopPath, desktopDirectoryFiles: desktopDirectoryFiles)
            
            
            let task = Process()
            task.executableURL = url
            
            if isToggled {
                // Manter arquivos excluídos no desktop e adicionar os novos arquivos
                await addFilesFromDevice(deviceDirectoryFiles: deviceDirectoryFiles, desktopDirectoryFiles: desktopDirectoryFiles, device: device, desktopPath: desktopPath, screenshotDir: screenshotDir)
                
               await modifyFilesFromDesktop(device: device, path: screenshotDir, desktopPath: desktopPath, deviceFilesDate: deviceFilesDate, desktopFilesDate: desktopFilesDate)
                
            } else {
                // Sincronizar e não manter arquivos excluídos no desktop
               await addFilesFromDevice(deviceDirectoryFiles: deviceDirectoryFiles, desktopDirectoryFiles: desktopDirectoryFiles, device: device, desktopPath: desktopPath, screenshotDir: screenshotDir)
                
               await removeFilesFromDesktop(deviceDirectoryFiles: deviceDirectoryFiles, desktopDirectoryFiles: desktopDirectoryFiles, desktopPath: desktopPath)
                
               await modifyFilesFromDesktop(device: device, path: screenshotDir, desktopPath: desktopPath, deviceFilesDate: deviceFilesDate, desktopFilesDate: desktopFilesDate)
            }
        } else {
            print("\nDiretório não encontrado no caminho: \(screenshotDir)")
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
    func runDeviceManufacturerApp(deviceName: String) async -> String {
        guard let service = await XPCservice() else {
            print("Erro: Conexão com o serviço XPC não foi estabelecida")
            return ""
        }
        
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                service.runDeviceManufacturer(deviceName: deviceName) { manufacturer in
                    continuation.resume(returning: manufacturer)
                }
            }
        }
    }
    
    // Modelo do device
    func runDeviceModelApp(deviceName: String) async -> String {
        guard let service = await XPCservice() else {
            print("Erro: Conexão com o serviço XPC não foi estabelecida")
            return ""
        }
        
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                service.runDeviceModel(deviceName: deviceName) { model in
                    continuation.resume(returning: model)
                }
            }
        }
    }
    
    func getDeviceDirectoryDateApp(deviceName: String, path: String) async -> Date {
        guard let service = await XPCservice() else {
            print("Erro: Conexão com o serviço XPC não foi estabelecida")
            return(Date())
        }
        
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                service.getDeviceDirectoryDate(deviceName: deviceName, path: path) { date in
                    continuation.resume(returning: date)
                }
            }
        }
    }
    
    func getDesktopDirectoryDate(of filePath: String) async -> Date? {
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
            print("O diretório do dispositivo foi modificado recentemente.")
        } else {
            isDirectoryUpdated = true
            print("O diretório no MacBook foi modificado recentemente ou é igual.")
        }
        return isDirectoryUpdated
        
    }
    
}



