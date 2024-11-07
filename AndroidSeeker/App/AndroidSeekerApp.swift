//
//  AndroidSeekerApp.swift
//  AndroidSeeker
//
//  Created by ifws on 23/09/24.
//

import SwiftUI

@main
struct AndroidSeekerApp: App {
    @StateObject private var deviceManager = DeviceManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 800, minHeight: 600)
                .environmentObject(deviceManager)
        }
    }
}
