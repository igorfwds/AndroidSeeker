//
//  DeviceInternListItemView.swift
//  AndroidSeeker
//
//  Created by ifws on 25/09/24.
//

import SwiftUI

struct DeviceInternListItemView: View {
    
    let file: File
    
    var body: some View {
        VStack(spacing: 5) {
            Image(systemName: "folder.fill")
                .resizable()
                .scaledToFit()
                .cornerRadius(10)
                .fixedSize(horizontal: false, vertical: true)
                .padding([.top, .leading, .trailing])
            Text(file.fileName)
                .font(.system(size: 10))
                .fontWeight(.bold)
                .padding(.bottom)
    
        }
        .frame(width: 80, height: 90)
    }
}

#Preview {
    DeviceInternListItemView(file: File(fileName: "test", parentFile: "root", subFiles: subFilesMock))
}
