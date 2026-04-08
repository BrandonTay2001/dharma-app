import SwiftUI

struct WelcomeView: View {
    @Bindable var viewModel: SuperwallViewModel
    @Bindable var onboardingViewModel: OnboardingViewModel

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                Spacer(minLength: DharmaTheme.Spacing.md)

                hero

                Spacer(minLength: DharmaTheme.Spacing.xl)

                benefits

                Spacer(minLength: DharmaTheme.Spacing.xl)

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
                DharmaTheme.Colors.cardHindu.opacity(0.58),
                DharmaTheme.Colors.cardBuddhist.opacity(0.22),
                Color.white
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var hero: some View {
        VStack(spacing: DharmaTheme.Spacing.md) {
            Text("Dharma's Journey")
                .font(DharmaTheme.Typography.uiLabel(12))
                .kerning(1.6)
                .foregroundColor(DharmaTheme.Colors.saffronDark)

            Text("What you unlock")
                .font(DharmaTheme.Typography.scriptureDisplay(40))
                .foregroundColor(DharmaTheme.Colors.onSurface)
        }
    }

    private var benefits: some View {
        VStack(spacing: DharmaTheme.Spacing.md) {
            benefitCard(
                symbol: "calendar.badge.clock",
                title: "Full personalised daily dharmic tasks",
                detail: "A plan shaped around your spiritual goals and chosen practices."
            )

            benefitCard(
                symbol: "sun.max",
                title: "Hindu and Buddhist calendar guidance",
                detail: "Ekadasi, festivals, deity days, and practice cues grounded in the traditions you selected."
            )

            benefitCard(
                symbol: "bubble.left.and.bubble.right",
                title: "AI spiritual mentor",
                detail: "Receive guidance on your spirituality on a daily basis, and ask follow-up questions on complex verses."
            )

            benefitCard(
                symbol: "book.pages.fill",
                title: "Verse library, streaks, and progress",
                detail: "Unlock 700+ verses across the Gita, Dhammapada, Upanishads, plus completion tracking and daily momentum."
            )
        }
    }

    private var footer: some View {
        VStack(spacing: DharmaTheme.Spacing.md) {
            Button {
                viewModel.presentPreLoginPaywall()
            } label: {
                Text("Get Started")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.saffron)

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
    WelcomeView(
        viewModel: SuperwallViewModel.shared,
        onboardingViewModel: OnboardingViewModel()
    )
}