//
//  DeviceView.swift
//  AndroidSeeker
//
//  Created by ifws on 25/09/24.
//

import SwiftUI

struct DeviceInternView: View {
    @EnvironmentObject private var deviceManager : DeviceManager
    var device: Device
    
    var body: some View {
        
        if deviceManager.isLoading{
            ProgressView()
        }
        else {
            DeviceInternListView(device: device)
                .onAppear{
                    print("||||||||||||||||||||||||||||||||||||||||||||||||||||\nNOME E FILES DO DEVICE CLICADO")
                    print(device.name)
                    print(device.files)
                }
        }
    }
}


#Preview {
    DeviceInternView(device: Device(name: deviceMock[0].name, status: deviceMock[0].status, files: deviceMock[0].files))
        .environmentObject(DeviceManager())
    
}
