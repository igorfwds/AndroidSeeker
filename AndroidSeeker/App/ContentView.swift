//
//  ContentView.swift
//  AndroidSeeker
//
//  Created by ifws on 23/09/24.
//

import SwiftUI

struct ContentView: View {
    @State private var adbOutput: String = "Pressione o botão para listar dispositivos"
    @StateObject private var deviceManager = DeviceManager()
    
    var body: some View {
        VStack {
            ScrollView{
                AppHeaderView()
                DeviceListView()
            }
            
        }
        .padding()
        .environmentObject(deviceManager)
    }
}


#Preview {
    ContentView()
}

