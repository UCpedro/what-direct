import SwiftUI

@main
struct WhatDirectApp: App {
    @StateObject private var viewModel = HomeViewModel()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(viewModel)
                .tint(WDTheme.brand)
        }
    }
}
