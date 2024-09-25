//
//  DeviceListView.swift
//  AndroidSeeker
//
//  Created by ifws on 25/09/24.
//

import SwiftUI

struct DeviceListView: View {
    
    var body: some View {
        NavigationStack {
            VStack (alignment: .leading, spacing: 30)  {
                ForEach(deviceMock) { dev in
                    NavigationLink(destination: DeviceInternView()){
                        Button( action: {
                            let deviceFiles = runLsCommand(device: dev)
                        }) {
                            DeviceListItemView(device: dev)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    DeviceListView()
}
