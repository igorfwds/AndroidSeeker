//
//  ContentView.swift
//  AndroidSeeker
//
//  Created by ifws on 23/09/24.
//

import SwiftUI

struct ContentView: View {
    @State private var adbOutput: String = "Pressione o botão para listar dispositivos"

    var body: some View {
        VStack {
            AppHeaderView()
            ScrollView{
                DeviceListView()
            }
            
            

            
        }
        .padding()
    }
}


#Preview {
    ContentView()
}

