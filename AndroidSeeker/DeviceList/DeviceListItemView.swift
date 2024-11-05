//
//  DeviceListItemView.swift
//  AndroidSeeker
//
//  Created by ifws on 25/09/24.
//

import SwiftUI

struct DeviceListItemView: View {
//    @EnvironmentObject
    let device: Device
    
    var body: some View {
        HStack {
                              
            Image(systemName: "iphone")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
            
            Text(device.name)
                .font(.title2)
                .fontWeight(.bold)
            Text(device.status)
                .font(.title2)
        }
    }
}

#Preview {
    DeviceListItemView(device:  Device(id: "298374", name: "ABBC775F", status: "device", files: filesMock))
}
