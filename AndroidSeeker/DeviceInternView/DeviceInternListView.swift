//
//  DeviceInternListView.swift
//  AndroidSeeker
//
//  Created by ifws on 25/09/24.
//

import SwiftUI

struct DeviceInternListView: View {
    var gridLayout: [GridItem] {
        return Array(repeating: GridItem(.flexible(), spacing: 20), count: 4)
    }
    
    var body: some View {
        LazyHGrid(rows: gridLayout, spacing: 15) {
            ForEach(filesMock) { file in
                DeviceInternListItemView(file: file)
            }
        }
    }}

#Preview {
    DeviceInternListView()
}
