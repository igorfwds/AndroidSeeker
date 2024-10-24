//
//  AppHeaderView.swift
//  AndroidSeeker
//
//  Created by ifws on 25/09/24.
//

import SwiftUI

struct AppHeaderView: View {
    @Binding var isToggled: Bool
    var body: some View {
        VStack {
            AppHeaderTitleView()
            
            AppHeaderRefreshButtonView(isToggled: $isToggled)
            Spacer()
        }
    }
}

#Preview {
    AppHeaderView(isToggled: .constant(true))
}
