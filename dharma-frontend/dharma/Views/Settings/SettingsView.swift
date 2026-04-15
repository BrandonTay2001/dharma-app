import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Environment(AuthViewModel.self) private var authViewModel
    @State private var showingDeleteAccountConfirmation = false
    @State private var showingSupportFallback = false
    @State private var showingSupportCopiedConfirmation = false
    
    private let supportEmailAddress = "virality.ventures.apps@gmail.com"
    
    var body: some View {
        VStack(spacing: 0) {
            // Drag indicator area + title
            HStack {
                Text("Settings")
                    .font(DharmaTheme.Typography.uiHeadline(18))
                    .foregroundColor(DharmaTheme.Colors.onSurface)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(DharmaTheme.Colors.secondaryText.opacity(0.5))
                }
            }
            .padding(.horizontal, DharmaTheme.Spacing.xl)
            .padding(.top, DharmaTheme.Spacing.xl)
            .padding(.bottom, DharmaTheme.Spacing.lg)
            
            Divider().opacity(0.3)

            HStack(spacing: DharmaTheme.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(DharmaTheme.Colors.saffron.opacity(0.12))
                        .frame(width: 48, height: 48)

                    Text(authViewModel.avatarInitial)
                        .font(DharmaTheme.Typography.uiHeadline(18))
                        .foregroundColor(DharmaTheme.Colors.saffron)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(authViewModel.primaryIdentityLabel)
                        .font(DharmaTheme.Typography.uiHeadline(16))
                        .foregroundColor(DharmaTheme.Colors.onSurface)
                        .lineLimit(1)

                    if let secondaryIdentityLabel = authViewModel.secondaryIdentityLabel {
                        Text(secondaryIdentityLabel)
                            .font(DharmaTheme.Typography.uiCaption())
                            .foregroundColor(DharmaTheme.Colors.secondaryText)
                            .lineLimit(1)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, DharmaTheme.Spacing.xl)
            .padding(.vertical, DharmaTheme.Spacing.lg)

            Divider().opacity(0.3)
            
            VStack(spacing: 0) {
                // Help & Support
                Button {
                    contactSupport()
                } label: {
                    HStack(spacing: DharmaTheme.Spacing.md) {
                        Image(systemName: "questionmark.circle")
                            .font(.system(size: 20))
                            .foregroundColor(DharmaTheme.Colors.saffron)
                            .frame(width: 28)
                        
                        Text("Help & Support")
                            .font(DharmaTheme.Typography.uiBody())
                            .foregroundColor(DharmaTheme.Colors.onSurface)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(DharmaTheme.Colors.secondaryText)
                    }
                    .padding(.horizontal, DharmaTheme.Spacing.xl)
                    .padding(.vertical, DharmaTheme.Spacing.lg)
                }
                
                Divider().padding(.leading, 68).opacity(0.3)
                
                // Log Out
                Button {
                    Task { await authViewModel.signOut() }
                    dismiss()
                } label: {
                    HStack(spacing: DharmaTheme.Spacing.md) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 20))
                            .foregroundColor(.red.opacity(0.8))
                            .frame(width: 28)
                        
                        Text("Log Out")
                            .font(DharmaTheme.Typography.uiBody())
                            .foregroundColor(.red.opacity(0.8))
                        
                        Spacer()
                    }
                    .padding(.horizontal, DharmaTheme.Spacing.xl)
                    .padding(.vertical, DharmaTheme.Spacing.lg)
                }
                .disabled(authViewModel.isDeletingAccount)

                Divider().padding(.leading, 68).opacity(0.3)

                Button {
                    showingDeleteAccountConfirmation = true
                } label: {
                    HStack(spacing: DharmaTheme.Spacing.md) {
                        Image(systemName: "trash")
                            .font(.system(size: 20))
                            .foregroundColor(.red.opacity(0.8))
                            .frame(width: 28)

                        Text(authViewModel.isDeletingAccount ? "Deleting Account..." : "Delete Account")
                            .font(DharmaTheme.Typography.uiBody())
                            .foregroundColor(.red.opacity(0.8))

                        Spacer()

                        if authViewModel.isDeletingAccount {
                            ProgressView()
                                .tint(.red.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, DharmaTheme.Spacing.xl)
                    .padding(.vertical, DharmaTheme.Spacing.lg)
                }
                .disabled(authViewModel.isDeletingAccount)
            }

            if let errorMessage = authViewModel.errorMessage {
                Text(errorMessage)
                    .font(DharmaTheme.Typography.uiCaption())
                    .foregroundColor(.red.opacity(0.85))
                    .padding(.horizontal, DharmaTheme.Spacing.xl)
                    .padding(.top, DharmaTheme.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer()
        }
        .background(Color.white)
        .alert("Delete account?", isPresented: $showingDeleteAccountConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    let deleted = await authViewModel.deleteAccount()

                    if deleted {
                        dismiss()
                    }
                }
            }
        } message: {
            Text("This permanently removes your Dharma account and all data tied to it, including your profile, journal entries, streaks, and daily completion history. You will not be able to sign in again with this account.")
        }
        .confirmationDialog("Contact support", isPresented: $showingSupportFallback, titleVisibility: .visible) {
            Button("Copy Email Address") {
                UIPasteboard.general.string = supportEmailAddress
                showingSupportCopiedConfirmation = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("We couldn't open an email app on this device.")
        }
        .alert("Support email copied", isPresented: $showingSupportCopiedConfirmation) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("The support email address is now on your clipboard.")
        }
    }

    private func contactSupport() {
        guard let supportURL = supportEmailURL else {
            showingSupportFallback = true
            return
        }

        openURL(supportURL) { accepted in
            if !accepted {
                showingSupportFallback = true
            }
        }
    }

    private var supportEmailURL: URL? {
        var components = URLComponents()
        components.scheme = "mailto"
        components.path = supportEmailAddress
        components.queryItems = [
            URLQueryItem(name: "subject", value: "Dharma Support")
        ]
        return components.url
    }
}

#Preview {
    let authViewModel = AuthViewModel()
    authViewModel.currentUserEmail = "seeker@dharma.app"
    authViewModel.currentUserDisplayName = "Brandon"

    return SettingsView()
        .environment(authViewModel)
        .presentationDetents([.height(430)])
}
