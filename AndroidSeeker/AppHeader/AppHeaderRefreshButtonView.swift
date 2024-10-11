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
                Task {
                    await deviceManager.runADBDevices()
                    devicesCheck()
                }
                
                print(deviceManager.devices)
                withAnimation(.linear(duration: 1.0)) {
                    rotationAngle += 360
                }
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .rotationEffect(.degrees(rotationAngle))
                    .frame(width: 50, height: 50)
                    .shadow(radius: 5)
            }
            .background(Color.white)
            .clipShape(Circle())
            
            
        }
        .alert(isPresented: $showAlert){
            Alert(title: Text("Android Seeker"), message: Text("Nenhum dispositivo encontrado."), dismissButton: .default(Text("Ok")))
        }
    }
    func devicesCheck() {
        if deviceManager.devices.isEmpty {
            showAlert = true
        }
    }
}
#Preview {
    AppHeaderRefreshButtonView()
}
