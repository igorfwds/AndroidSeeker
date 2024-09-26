//
//  DeviceView.swift
//  AndroidSeeker
//
//  Created by ifws on 25/09/24.
//

import SwiftUI

struct DeviceInternView: View {
    
    var device: Device
    
    var body: some View {
        
        DeviceInternListView(device: device)
    }
}

#Preview {
    DeviceInternView(device: Device(id: deviceMock[0].id  , name: deviceMock[0].name, status: deviceMock[0].status, files: deviceMock[0].files))
    
}
