//
//  AppHeaderRefreshButtonView.swift
//  AndroidSeeker
//
//  Created by ifws on 25/09/24.
//

import SwiftUI

struct AppHeaderRefreshButtonView: View {
    var body: some View {
        HStack{
            Button(action: {
                let result = runADBDevices()
            }) {
                Image(systemName: "arrow.clockwise")
                    .font(.title3)
                    .foregroundColor(.blue)
                    .padding(20)
            }
            .background(Color.white)
            .clipShape(Circle())
        }
    }
}

#Preview {
    AppHeaderRefreshButtonView()
}
