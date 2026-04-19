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
    @State private var onboardingViewModel = OnboardingViewModel()
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            Group {
                if showSplash {
                    BreatheSplashView {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showSplash = false
                        }
                    }
                } else if superwallViewModel.hasCompletedOnboarding && superwallViewModel.hasUnlockedAuthFlow {
                    if authViewModel.isAuthenticated {
                        if superwallViewModel.isConfigured && !superwallViewModel.isSubscribed {
                            SubscriptionRequiredView(
                                superwallViewModel: superwallViewModel,
                                authViewModel: authViewModel
                            )
                        } else {
                            ContentView()
                        }
                    } else {
                        SignInView(viewModel: authViewModel)
                    }
                } else {
                    OnboardingView(
                        viewModel: onboardingViewModel,
                        superwallViewModel: superwallViewModel,
                        authViewModel: authViewModel
                    )
                }
            }
            .environment(authViewModel)
            .environment(superwallViewModel)
            .preferredColorScheme(.light)
        }
    }
}
