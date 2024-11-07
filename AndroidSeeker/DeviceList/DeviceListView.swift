//
//  DeviceListView.swift
//  AndroidSeeker
//
//  Created by ifws on 25/09/24.
//

import SwiftUI

struct DeviceListView: View {
    //    @State private var notFoundMessage
    @EnvironmentObject private var deviceManager : DeviceManager
    @Binding var isToggled: Bool
    
    var body: some View {
        
        if deviceManager.isLoading{
            ProgressView()
        }
        else {
            VStack(alignment: .leading, spacing: 30) {
                if !deviceManager.devices.isEmpty {
                    ForEach(deviceManager.devices) { dev in
                        NavigationLink(destination: DeviceInternView(device: dev)
                            .onAppear{
                                Task{
                                    await deviceManager.copyScreenshotDir(device: dev, isToggled: isToggled)
                                    await deviceManager.runLsCommand(deviceName: dev.name)
                                }
                                
                            }) {
                                DeviceListItemView(device: dev)
                                
                            }
                        
                            .cornerRadius(50)
                    }
                    .onAppear{
                        print("AQUI ESTAO OS DEVICES")
                        print(deviceManager.devices)
                    }
                }else{
                    
                    ContentUnavailableView("Nehum Dispositivo Encontrado...", systemImage: "iphone.gen3.slash", description: Text("Favor apertar o botão de buscar."))
                        .frame(minWidth: 1600)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                }
            }
            
            .padding()
        }
    }
}



#Preview {
    NavigationStack {
        DeviceListView(isToggled: .constant(true))
            .environmentObject(DeviceManager())
    }
}
