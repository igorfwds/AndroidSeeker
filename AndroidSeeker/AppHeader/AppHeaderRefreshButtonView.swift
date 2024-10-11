//
//  AppHeaderRefreshButtonView.swift
//  AndroidSeeker
//
//  Created by ifws on 25/09/24.
//

import SwiftUI


struct AppHeaderRefreshButtonView: View {
    @State private var rotationAngle: Double = 0
    @EnvironmentObject var deviceManager: DeviceManager
    @State private var showAlert = false
    
    var body: some View {
            HStack {
                Button(action: {
                    deviceManager.isLoading = true
                    deviceManager.runADBDevices()
                    
                    print(deviceManager.devices)
                    withAnimation(.linear(duration: 1.0)) {
                        rotationAngle += 360
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .padding(20)
                        .rotationEffect(.degrees(rotationAngle))
        HStack {
            Button(action: {
                Task {
                    await deviceManager.runADBDevices()
                    devicesCheck()
                }
                print(deviceManager.devices)
                
            
                withAnimation(.linear(duration: 1.0)) {
                    rotationAngle += 360
                }
                .background(Color.white)
                .clipShape(Circle())
            }
            .background(.white)
            .clipShape(Circle())
            
        }.alert(isPresented: $showAlert){
            Alert(title: Text("Android Seeker"), message: Text("Nenhum dispositivo encontrado."), dismissButton: .default(Text("Ok")))
        }
        
    }
    
    func devicesCheck() {
        DispatchQueue.global(qos: .background).async {
            if deviceManager.devices.isEmpty {
                showAlert = true
            }
        }
    }
}

#Preview {
    AppHeaderRefreshButtonView()
}
