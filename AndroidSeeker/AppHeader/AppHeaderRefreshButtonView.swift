//
//  AppHeaderRefreshButtonView.swift
//  AndroidSeeker
//
//  Created by ifws on 25/09/24.
//

import SwiftUI


struct AppHeaderRefreshButtonView: View {
    let defaults = UserDefaults.standard
    @State private var rotationAngle: Double = 0
    @EnvironmentObject var deviceManager: DeviceManager
    @State private var showAlert = false
    @Binding var isToggled: Bool
    
    var body: some View {
        HStack {
            Button(action: {

                deviceManager.isLoading = true
                Task {
                    await deviceManager.runADBDevices()
                    devicesCheck()
                }
//                print(deviceManager.devices)
                
            
                withAnimation(.linear(duration: 1.0)) {
                    rotationAngle += 360
                }
            }) {
                Image(systemName: "arrow.clockwise")
//                Text("Listar dispositivos")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .padding(20)
                    .cornerRadius(5.0)
                    .rotationEffect(.degrees(rotationAngle))
                    .frame(width: 50, height: 50)
                    .shadow(radius: 5)
            }
            .background(.white)
            .clipShape(Circle())
            
            
            
        }
        .alert(isPresented: $showAlert){
            Alert(title: Text("Android Seeker"), message: Text("Nenhum dispositivo encontrado."), dismissButton: .default(Text("Ok")))
        }
        
        Toggle(isOn: $isToggled) {
            Text("Manter arquivos apagados")
        }
        .font(.title3)
        .toggleStyle(.switch)
        .padding()
        
    }
//    func devicesCheck() {
//        if deviceManager.devices.isEmpty {
//            showAlert = true
//        }.alert(isPresented: $showAlert){
//            Alert(title: Text("Android Seeker"), message: Text("Nenhum dispositivo encontrado."), dismissButton: .default(Text("Ok")))
//        }
//    }
    
    func devicesCheck() {
        DispatchQueue.global(qos: .background).async {
            if deviceManager.devices.isEmpty {
                showAlert = true
            }
        }
    }
}
#Preview {
    AppHeaderRefreshButtonView( isToggled: .constant(true))
}
