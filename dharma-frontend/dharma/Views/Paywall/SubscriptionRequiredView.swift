import SwiftUI

struct SubscriptionRequiredView: View {
    @Bindable var superwallViewModel: SuperwallViewModel
    @Bindable var authViewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: DharmaTheme.Spacing.md) {
                Image(systemName: "lock.shield")
                    .font(.system(size: 56, weight: .light))
                    .foregroundColor(DharmaTheme.Colors.saffron)

                Text("Subscription Required")
                    .font(DharmaTheme.Typography.scriptureDisplay(28))
                    .foregroundColor(DharmaTheme.Colors.onSurface)

                Text("Your subscription is no longer active. Resubscribe to continue your spiritual journey.")
                    .font(DharmaTheme.Typography.uiBody())
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DharmaTheme.Spacing.lg)
            }

            Spacer()

            VStack(spacing: DharmaTheme.Spacing.md) {
                if let errorMessage = superwallViewModel.errorMessage {
                    Text(errorMessage)
                        .font(DharmaTheme.Typography.uiCaption())
                        .foregroundColor(.red.opacity(0.85))
                        .multilineTextAlignment(.center)
                }

                Button {
                    superwallViewModel.presentResubscribePaywall()
                } label: {
                    Text("Resubscribe")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.saffron)

                Button {
                    Task { await authViewModel.signOut() }
                } label: {
                    Text("Sign Out")
                        .font(DharmaTheme.Typography.uiBody(14))
                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                }
                .padding(.top, DharmaTheme.Spacing.sm)
            }
            .padding(.horizontal, DharmaTheme.Spacing.xl)
            .padding(.bottom, DharmaTheme.Spacing.xxl)
        }
        .background(Color.white)
        .onAppear {
            superwallViewModel.errorMessage = nil
        }
    }
}
