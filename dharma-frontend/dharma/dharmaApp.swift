//
//  dharmaApp.swift
//  dharma
//
//  Created by Brandon Tay on 24/3/2026.
//

import SwiftUI

@main
struct dharmaApp: App {
    @State private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                ContentView()
                    .environment(authViewModel)
            } else {
                SignInView(viewModel: authViewModel)
            }
        }
    }
}
