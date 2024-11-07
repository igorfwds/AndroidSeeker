//
//  DeviceInternListView.swift
//  AndroidSeeker
//
//  Created by ifws on 25/09/24.
//

import SwiftUI

struct DeviceInternListView: View {
    var device: Device
    
    
    var gridLayout: [GridItem] {
        return Array(repeating: GridItem(.flexible(), spacing: 20), count: 4)
    }
    
    var body: some View {
        LazyHGrid(rows: gridLayout, spacing: 15) {
            ForEach(device.files) { file in
                DeviceInternListItemView(file: file)
            }
        }
    }}

#Preview {
    DeviceInternListView(device: Device(id: deviceMock[0].id  , name: deviceMock[0].name, status: deviceMock[0].status, files: deviceMock[0].files))
}

