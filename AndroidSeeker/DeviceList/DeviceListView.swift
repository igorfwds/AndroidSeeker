//
//  DeviceListView.swift
//  AndroidSeeker
//
//  Created by ifws on 25/09/24.
//

import SwiftUI

struct DeviceListView: View {
//    @State private var notFoundMessage
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 30) {
                ForEach(devices) { dev in
                    NavigationLink(destination: DeviceInternView(device: dev)) {
                        DeviceListItemView(device: dev)
                    }
                    // Executa a ação de rodar o comando ao mesmo tempo que a navegação, sem adicionar efeito de botão
                    .onTapGesture {
                        let deviceFiles = runLsCommand(device: dev)
//                        if deviceFiles.isEmpty {
//                            Text("No files found")
//                        }
                    }
                    .cornerRadius(50)
                }
            }
            .padding()
        }
    }
}


#Preview {
    DeviceListView()
}
