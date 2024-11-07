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
    @AppStorage ("isToggled") private var isToggled: Bool = UserDefaults.standard.isToggled
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView{
                    AppHeaderView(isToggled: $isToggled)
                    DeviceListView(isToggled: $isToggled)
                }
                
            }
            .padding()
            .environmentObject(deviceManager)
        }
    }
}


#Preview {
    ContentView()
}

