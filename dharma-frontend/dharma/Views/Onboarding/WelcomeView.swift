import SwiftUI

struct WelcomeView: View {
    @Bindable var viewModel: SuperwallViewModel

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                Spacer(minLength: DharmaTheme.Spacing.xxxl)

                hero

                Spacer()

                benefits

                Spacer()

                footer
            }
            .padding(.horizontal, DharmaTheme.Spacing.xl)
            .padding(.vertical, DharmaTheme.Spacing.xxl)
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color.white,
                DharmaTheme.Colors.cardHindu.opacity(0.6),
                DharmaTheme.Colors.cardBuddhist.opacity(0.35),
                Color.white
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topTrailing) {
            Circle()
                .fill(DharmaTheme.Colors.saffron.opacity(0.08))
                .frame(width: 220, height: 220)
                .offset(x: 70, y: -40)
        }
        .overlay(alignment: .bottomLeading) {
            Circle()
                .fill(DharmaTheme.Colors.cardBuddhist.opacity(0.55))
                .frame(width: 180, height: 180)
                .offset(x: -70, y: 40)
        }
        .ignoresSafeArea()
    }

    private var hero: some View {
        VStack(spacing: DharmaTheme.Spacing.lg) {
            Text("Dharma")
                .font(DharmaTheme.Typography.scriptureDisplay(44))
                .foregroundColor(DharmaTheme.Colors.onSurface)

            Text("A quieter path into daily practice")
                .font(DharmaTheme.Typography.uiHeadline(20))
                .foregroundColor(DharmaTheme.Colors.saffron)

            Text("Scripture, meditation, mantra, and reflection arranged into one grounded spiritual journey.")
                .font(DharmaTheme.Typography.uiBody(17))
                .foregroundColor(DharmaTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, DharmaTheme.Spacing.md)
        }
    }

    private var benefits: some View {
        VStack(spacing: DharmaTheme.Spacing.md) {
            benefitCard(
                symbol: "sun.max",
                title: "Begin with intention",
                detail: "Move through a daily verse, guided meditation, mantra, and gratitude ritual."
            )

            benefitCard(
                symbol: "book.closed",
                title: "Study sacred texts",
                detail: "Read from curated Buddhist and Hindu teachings with a calm, focused interface."
            )

            benefitCard(
                symbol: "bubble.left.and.bubble.right",
                title: "Receive guided insight",
                detail: "Open spiritual guidance after subscribing and carry that access into your account."
            )
        }
    }

    private var footer: some View {
        VStack(spacing: DharmaTheme.Spacing.md) {
            Button {
                viewModel.presentPreLoginPaywall()
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.saffron)

            Text("Continue opens the subscription paywall. If you dismiss it, you will remain on this welcome screen until access is unlocked.")
                .font(DharmaTheme.Typography.uiCaption())
                .foregroundColor(DharmaTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(DharmaTheme.Typography.uiCaption())
                    .foregroundColor(.red.opacity(0.85))
                    .multilineTextAlignment(.center)
            }
        }
    }

    private func benefitCard(symbol: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: DharmaTheme.Spacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: DharmaTheme.Radius.md)
                    .fill(DharmaTheme.Colors.saffron.opacity(0.12))
                    .frame(width: 46, height: 46)

                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(DharmaTheme.Colors.saffron)
            }

            VStack(alignment: .leading, spacing: DharmaTheme.Spacing.xs) {
                Text(title)
                    .font(DharmaTheme.Typography.uiHeadline(16))
                    .foregroundColor(DharmaTheme.Colors.onSurface)

                Text(detail)
                    .font(DharmaTheme.Typography.uiBody(14))
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
                    .lineSpacing(3)
            }

            Spacer()
        }
        .padding(DharmaTheme.Spacing.lg)
        .background(DharmaTheme.Colors.surfaceContainerLowest.opacity(0.9))
        .cornerRadius(DharmaTheme.Radius.lg)
    }
}

#Preview {
    WelcomeView(viewModel: SuperwallViewModel.shared)
}