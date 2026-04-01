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
    @State private var superwallViewModel = SuperwallViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if superwallViewModel.hasUnlockedAuthFlow {
                    if authViewModel.isAuthenticated {
                        ContentView()
                    } else {
                        SignInView(viewModel: authViewModel)
                    }
                } else {
                    WelcomeView(viewModel: superwallViewModel)
                }
            }
            .environment(authViewModel)
            .environment(superwallViewModel)
        }
    }
}
