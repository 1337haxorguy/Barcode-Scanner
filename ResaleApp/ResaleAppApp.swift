//
//  ResaleAppApp.swift
//  ResaleApp
//
//  Created by Angelo Dela Fuente on 6/4/24.
//

import SwiftUI

@main
struct ResaleAppApp: App {
    
    @StateObject private var viewModel = AppViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .task {
                    await viewModel.RequestScannerAccess()
                }
        }
    }
}
