import SwiftUI

struct WelcomeView: View {
    @Bindable var viewModel: SuperwallViewModel
    @Bindable var onboardingViewModel: OnboardingViewModel

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                Spacer(minLength: DharmaTheme.Spacing.xxl)

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
        VStack(spacing: DharmaTheme.Spacing.md) {
            Text("Premium")
                .font(DharmaTheme.Typography.uiLabel(12))
                .kerning(1.6)
                .foregroundColor(DharmaTheme.Colors.saffronDark)

            Text("What you unlock")
                .font(DharmaTheme.Typography.scriptureDisplay(40))
                .foregroundColor(DharmaTheme.Colors.onSurface)

            Text(heroSubtitle)
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
                symbol: "calendar.badge.clock",
                title: "Full personalised daily dharmic task",
                detail: "A plan shaped around \(onboardingViewModel.primaryGoalSummary.lowercased()) and your chosen practices."
            )

            benefitCard(
                symbol: "sun.max",
                title: "Hindu and Buddhist calendar guidance",
                detail: "Ekadasi, festivals, deity days, and practice cues grounded in the traditions you selected."
            )

            benefitCard(
                symbol: "bubble.left.and.bubble.right",
                title: "Unlimited AI spiritual mentor",
                detail: "Ask as many follow-up questions as you need, then move into meditations, breathwork, and the full verse library."
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
                Text("Let's go")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.saffron)

            Text("You'll continue to account access once premium is active.")
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

    private var heroSubtitle: String {
        let nameFragment = onboardingViewModel.trimmedName.isEmpty ? "" : "\(onboardingViewModel.trimmedName), "
        let goalFragment = onboardingViewModel.secondaryGoalSummary.map { " and \($0)" } ?? ""

        return "\(nameFragment)your plan is ready for \(onboardingViewModel.primaryGoalSummary.lowercased())\(goalFragment), with \(onboardingViewModel.selectedPracticeSummary)."
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