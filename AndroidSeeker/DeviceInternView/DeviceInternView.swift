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
        DeviceInternListView(device: device)
    }
}

#Preview {
    DeviceInternView(device: Device(id: "298374", name: deviceMock[0].name, status: deviceMock[0].status, files: deviceMock[0].files))
        .environmentObject(DeviceManager())
    
}
