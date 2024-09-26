//
//  AppHeaderRefreshButtonView.swift
//  AndroidSeeker
//
//  Created by ifws on 25/09/24.
//

import SwiftUI

struct AppHeaderRefreshButtonView: View {
    @State private var rotationAngle: Double = 0

    var body: some View {
        HStack {
            Button(action: {
                let result = runADBDevices()
                withAnimation(.linear(duration: 1.0)) {
                    rotationAngle += 360
                }
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .padding(20)
                    .rotationEffect(.degrees(rotationAngle))
            }
            .background(Color.white)
            .clipShape(Circle())
        }
        
    }
}

#Preview {
    AppHeaderRefreshButtonView()
}
