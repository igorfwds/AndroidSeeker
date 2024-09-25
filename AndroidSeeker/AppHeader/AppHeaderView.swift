//
//  AppHeaderView.swift
//  AndroidSeeker
//
//  Created by ifws on 25/09/24.
//

import SwiftUI

struct AppHeaderView: View {
    var body: some View {
        VStack {
            AppHeaderTitleView()
            
            AppHeaderRefreshButtonView()
            Spacer()
        }
    }
}

#Preview {
    AppHeaderView()
}
