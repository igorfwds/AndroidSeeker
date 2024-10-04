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
    var body: some View {
        

                VStack(alignment: .leading, spacing: 30) {
                    ForEach(deviceManager.devices) { dev in
                        NavigationLink(destination: DeviceInternView(device: dev)
                            .onAppear{
                            deviceManager.runLsCommand(device: dev)
                            deviceManager.copyScreenshotDir(device: dev)
                        }) {
                            DeviceListItemView(device: dev)
                                
                        }
                        
                        .cornerRadius(50)
                    }
                }
                .padding()
        }
    }



#Preview {
    NavigationStack {
        DeviceListView()
            .environmentObject(DeviceManager())
    }
}
