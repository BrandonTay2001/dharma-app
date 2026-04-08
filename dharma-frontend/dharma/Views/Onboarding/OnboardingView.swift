import StoreKit
import SwiftUI

struct OnboardingView: View {
    @Environment(\.openURL) private var openURL
    @Environment(\.requestReview) private var requestReview

    @Bindable var viewModel: OnboardingViewModel
    @Bindable var superwallViewModel: SuperwallViewModel
    @Bindable var authViewModel: AuthViewModel

    private let privacyPolicyURL = URL(string: "https://sites.google.com/view/dharmaprivacyterms")!

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                if viewModel.currentStep.showsHeader {
                    header
                }

                ScrollView(showsIndicators: false) {
                    currentStepContent
                        .padding(.horizontal, DharmaTheme.Spacing.xl)
                        .padding(.top, viewModel.currentStep == .premium ? DharmaTheme.Spacing.xl : DharmaTheme.Spacing.lg)
                        .padding(.bottom, DharmaTheme.Spacing.xxxl)
                }
                .scrollBounceBehavior(.basedOnSize)

                if viewModel.currentStep.showsContinueButton {
                    bottomCTA
                }
            }
        }
        .alert("Continue onboarding", isPresented: $viewModel.showSignInAlert) {
            Button("Continue") {}
        } message: {
            Text("Sign in unlocks after subscription access is confirmed. Finish onboarding and continue to the premium screen first.")
        }
        .task(id: viewModel.currentStep) {
            if viewModel.currentStep == .generatingPlan {
                await viewModel.beginPlanGenerationIfNeeded()
            }
        }
    }

    private var background: some View {
        DharmaTheme.Colors.cardHindu.opacity(0.34)
        .ignoresSafeArea()
    }

    private var header: some View {
        VStack(spacing: DharmaTheme.Spacing.md) {
            HStack {
                Button {
                    viewModel.goBack()
                } label: {
                    Image(systemName: "arrow.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DharmaTheme.Colors.onSurface)
                        .frame(width: 40, height: 40)
                        .background(DharmaTheme.Colors.surfaceContainerLowest.opacity(0.92))
                        .clipShape(Circle())
                }
                .opacity(viewModel.currentStep == .consent ? 1 : 1)

                Spacer()

                Text("Dharma")
                    .font(DharmaTheme.Typography.scriptureHeadline(20))
                    .foregroundColor(DharmaTheme.Colors.onSurface)

                Spacer()

                Circle()
                    .fill(Color.clear)
                    .frame(width: 40, height: 40)
            }

            ProgressView(value: viewModel.currentStep.progressValue)
                .tint(DharmaTheme.Colors.saffron)
                .scaleEffect(x: 1, y: 1.2, anchor: .center)
        }
        .padding(.horizontal, DharmaTheme.Spacing.xl)
        .padding(.top, DharmaTheme.Spacing.lg)
        .padding(.bottom, DharmaTheme.Spacing.md)
    }

    @ViewBuilder
    private var currentStepContent: some View {
        switch viewModel.currentStep {
        case .intro:
            introStep
        case .consent:
            consentStep
        case .name:
            nameStep
        case .belief:
            beliefStep
        case .gender:
            genderStep
        case .ageRange:
            ageRangeStep
        case .goals:
            goalsStep
        case .practices:
            practicesStep
        case .timeAvailable:
            dailyTimeStep
        case .productTour:
            productTourStep
        case .socialProof:
            socialProofStep
        case .notifications:
            notificationsStep
        case .widgets:
            widgetsStep
        case .generatingPlan:
            generatingStep
        case .premium:
            WelcomeView(viewModel: superwallViewModel, onboardingViewModel: viewModel)
                .task {
                    viewModel.prepareAuth(authViewModel)
                }
        }
    }

    private var bottomCTA: some View {
        VStack(spacing: DharmaTheme.Spacing.sm) {
            Button {
                handleContinueTap()
            } label: {
                Text(buttonTitle)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.saffron)
            .disabled(!viewModel.canContinue)
            .opacity(viewModel.canContinue ? 1 : 0.55)

            if viewModel.currentStep == .consent {
                Button("Privacy Policy") {
                    openURL(privacyPolicyURL)
                }
                .font(DharmaTheme.Typography.uiCaption(13))
                .foregroundColor(DharmaTheme.Colors.saffronDark)
                .buttonStyle(.plain)
                .padding(.top, DharmaTheme.Spacing.xs)
            }
        }
        .padding(.horizontal, DharmaTheme.Spacing.xl)
        .padding(.top, DharmaTheme.Spacing.md)
        .padding(.bottom, DharmaTheme.Spacing.xxl)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0), Color.white.opacity(0.94), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .bottom)
        )
    }

    private func handleContinueTap() {
        if viewModel.currentStep == .notifications {
            Task {
                await viewModel.requestNotificationPermission()
            }
            return
        }

        viewModel.advance()
    }

    private var buttonTitle: String {
        switch viewModel.currentStep {
        case .intro:
            return "Start my journey"
        case .consent:
            return "I understand - let's continue"
        case .timeAvailable:
            return "Build my plan"
        case .notifications:
            return "Allow Notifications"
        case .widgets:
            return "Continue"
        default:
            return "Continue"
        }
    }

    private var introStep: some View {
        VStack(spacing: DharmaTheme.Spacing.xxl) {
            VStack(spacing: DharmaTheme.Spacing.lg) {
                Text("Your path to dharma begins here")
                    .font(DharmaTheme.Typography.scriptureDisplay(38))
                    .foregroundColor(DharmaTheme.Colors.onSurface)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, DharmaTheme.Spacing.xxxl)

            VStack(spacing: DharmaTheme.Spacing.md) {
                introCard(
                    symbol: "sun.max.fill",
                    title: "Daily guidance that feels grounded",
                    detail: "Verses, meditations, mantra, and reflection gathered into one clean ritual each morning."
                )

                introCard(
                    symbol: "sparkles",
                    title: "An AI mentor shaped by sacred traditions",
                    detail: "Ask questions about purpose, practice, and daily life with answers anchored in timeless teachings."
                )

                introCard(
                    symbol: "calendar.badge.clock",
                    title: "A plan that fits your real schedule",
                    detail: "Short, steady sessions that adapt to the time and practices you actually want to keep."
                )
            }

            Button {
                viewModel.advance()
            } label: {
                Text("Start my journey")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.saffron)

            HStack(spacing: DharmaTheme.Spacing.xs) {
                Text("I already have an account")
                    .font(DharmaTheme.Typography.uiBody(14))
                    .foregroundColor(DharmaTheme.Colors.secondaryText)

                Button("Sign in") {
                    viewModel.handleSignInTap(superwallViewModel: superwallViewModel, authViewModel: authViewModel)
                }
                .font(DharmaTheme.Typography.uiHeadline(14))
                .foregroundColor(DharmaTheme.Colors.saffron)
            }
            .padding(.bottom, DharmaTheme.Spacing.xxl)
        }
    }

    private var consentStep: some View {
        stepLayout(
            eyebrow: "Consent",
            title: "Your journey, your data."
        ) {
            VStack(spacing: DharmaTheme.Spacing.lg) {
                infoCard(
                    title: "We collect",
                    body: "Spiritual preferences, age range, goals, and practice choices only to personalise your experience."
                )

                infoCard(
                    title: "Transparency",
                    body: "Dharma is built upon timeless Hindu and Buddhist teachings that are freely available in the public domain, presented as a clean sanctuary for modern mindfulness."
                )
            }
        }
    }

    private var nameStep: some View {
        stepLayout(
            eyebrow: "Profile",
            title: "What's your name?"
        ) {
            VStack(alignment: .leading, spacing: DharmaTheme.Spacing.sm) {
                Text("Name")
                    .font(DharmaTheme.Typography.uiCaption())
                    .foregroundColor(DharmaTheme.Colors.secondaryText)

                TextField("Your name", text: $viewModel.name)
                    .textContentType(.name)
                    .font(DharmaTheme.Typography.uiBody(17))
                    .padding(DharmaTheme.Spacing.lg)
                    .background(DharmaTheme.Colors.surfaceContainerLowest.opacity(0.96))
                    .clipShape(RoundedRectangle(cornerRadius: DharmaTheme.Radius.lg, style: .continuous))
            }
        }
    }

    private var beliefStep: some View {
        stepLayout(
            eyebrow: "Tradition",
            title: "What tradition speaks to your soul?"
        ) {
            optionList(
                items: OnboardingViewModel.SpiritualBelief.allCases,
                selectionContains: { viewModel.selectedBeliefs.contains($0) },
                title: \ .title,
                action: viewModel.toggleBelief
            )
        }
    }

    private var genderStep: some View {
        stepLayout(
            eyebrow: "Identity",
            title: "How do you identify?"
        ) {
            optionList(
                items: OnboardingViewModel.GenderIdentity.allCases,
                selectionContains: { viewModel.gender == $0 },
                title: \ .title,
                action: { viewModel.gender = $0 }
            )
        }
    }

    private var ageRangeStep: some View {
        stepLayout(
            eyebrow: "Age range",
            title: "What's your age range?"
        ) {
            optionList(
                items: OnboardingViewModel.AgeRange.allCases,
                selectionContains: { viewModel.ageRange == $0 },
                title: \ .title,
                action: { viewModel.ageRange = $0 }
            )
        }
    }

    private var goalsStep: some View {
        stepLayout(
            eyebrow: "Goal",
            title: "What brings you here today?"
        ) {
            VStack(alignment: .leading, spacing: DharmaTheme.Spacing.sm) {
                Text("Selected: \(viewModel.selectedGoals.count)/2")
                    .font(DharmaTheme.Typography.uiCaption())
                    .foregroundColor(DharmaTheme.Colors.secondaryText)

                optionList(
                    items: OnboardingViewModel.Goal.allCases,
                    selectionContains: { viewModel.selectedGoals.contains($0) },
                    title: \ .title,
                    action: viewModel.toggleGoal
                )
            }
        }
    }

    private var practicesStep: some View {
        stepLayout(
            eyebrow: "Practice preferences",
            title: "Which practices call to you?"
        ) {
            optionList(
                items: OnboardingViewModel.Practice.allCases,
                selectionContains: { viewModel.selectedPractices.contains($0) },
                title: \ .title,
                action: viewModel.togglePractice
            )
        }
    }

    private var dailyTimeStep: some View {
        stepLayout(
            eyebrow: "Time available",
            title: "How much time can you give to your practice each day?"
        ) {
            optionList(
                items: OnboardingViewModel.DailyTime.allCases,
                selectionContains: { viewModel.dailyTime == $0 },
                title: \ .title,
                action: { viewModel.dailyTime = $0 }
            )
        }
    }

    private var productTourStep: some View {
        stepLayout(
            eyebrow: "What Dharma does",
            title: "Built to guide the whole day",
            subtitle: "Swipe through the core experience before we build your plan."
        ) {
            VStack(spacing: DharmaTheme.Spacing.lg) {
                TabView(selection: $viewModel.currentProductPanel) {
                    ForEach(viewModel.productPanels) { panel in
                        VStack(alignment: .leading, spacing: DharmaTheme.Spacing.lg) {
                            ZStack {
                                RoundedRectangle(cornerRadius: DharmaTheme.Radius.xl, style: .continuous)
                                    .fill(DharmaTheme.Colors.surfaceContainerLowest.opacity(0.96))

                                VStack(alignment: .leading, spacing: DharmaTheme.Spacing.lg) {
                                    Image(systemName: panel.symbol)
                                        .font(.system(size: 28, weight: .medium))
                                        .foregroundColor(DharmaTheme.Colors.saffron)
                                        .frame(width: 58, height: 58)
                                        .background(DharmaTheme.Colors.saffron.opacity(0.12))
                                        .clipShape(RoundedRectangle(cornerRadius: DharmaTheme.Radius.lg, style: .continuous))

                                    Text(panel.title)
                                        .font(DharmaTheme.Typography.scriptureHeadline(26))
                                        .foregroundColor(DharmaTheme.Colors.onSurface)

                                    Text(panel.body)
                                        .font(DharmaTheme.Typography.uiBody(16))
                                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                                        .lineSpacing(4)

                                    if panel.id == 2 {
                                        Text("Example: Today is Ekadasi. Fast until sunset. Chant: Om Namo Bhagavate Vasudevaya. 7 min pranayama.")
                                            .font(DharmaTheme.Typography.uiCaption(13))
                                            .foregroundColor(DharmaTheme.Colors.onSurfaceVariant)
                                            .padding(DharmaTheme.Spacing.md)
                                            .background(DharmaTheme.Colors.cardHindu.opacity(0.6))
                                            .clipShape(RoundedRectangle(cornerRadius: DharmaTheme.Radius.md, style: .continuous))
                                    }
                                }
                                .padding(DharmaTheme.Spacing.xl)
                            }
                        }
                        .tag(panel.id)
                    }
                }
                .frame(height: 380)
                .tabViewStyle(.page(indexDisplayMode: .never))

                HStack(spacing: DharmaTheme.Spacing.sm) {
                    ForEach(viewModel.productPanels) { panel in
                        Capsule()
                            .fill(panel.id == viewModel.currentProductPanel ? DharmaTheme.Colors.saffron : DharmaTheme.Colors.outlineVariant)
                            .frame(width: panel.id == viewModel.currentProductPanel ? 28 : 8, height: 8)
                    }
                }
            }
        }
    }

    private var socialProofStep: some View {
        VStack(alignment: .leading, spacing: DharmaTheme.Spacing.xl) {
            VStack(alignment: .leading, spacing: DharmaTheme.Spacing.md) {
                Text("WHY SEEKERS STAY")
                    .font(DharmaTheme.Typography.uiLabel(12))
                    .kerning(1.2)
                    .foregroundColor(DharmaTheme.Colors.saffronDark)

                HStack {
                    Spacer()
                    reviewBanner
                    Spacer()
                }

                Text("A calmer ritual, not another noisy wellness app")
                    .font(DharmaTheme.Typography.scriptureHeadline(32))
                    .foregroundColor(DharmaTheme.Colors.onSurface)
            }

            VStack(spacing: DharmaTheme.Spacing.lg) {
                statisticCard(value: "5 min", label: "Daily practice is enough to create momentum")
                statisticCard(value: "700+", label: "Verses and teachings across the library")
                socialQuote("It feels like having a wise guide that doesn't overwhelm me.")
                socialQuote("The app tells me exactly what to do each morning, which makes consistency easier.")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .task {
            guard !viewModel.hasRequestedReviewPrompt else {
                return
            }

            viewModel.hasRequestedReviewPrompt = true
            requestReview()
        }
    }

    private var reviewBanner: some View {
        VStack(spacing: DharmaTheme.Spacing.xs) {
            HStack(spacing: DharmaTheme.Spacing.sm) {
                Text("4.8")
                    .font(.system(size: 23, weight: .bold, design: .rounded))
                    .foregroundColor(DharmaTheme.Colors.onSurface)

                HStack(spacing: 3) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(DharmaTheme.Colors.saffron)
                    }
                }
            }

            Text("100K+ App Ratings")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundColor(DharmaTheme.Colors.secondaryText)
        }
        .padding(.horizontal, DharmaTheme.Spacing.lg)
        .padding(.vertical, DharmaTheme.Spacing.lg)
        .background(DharmaTheme.Colors.surfaceContainerLow.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: DharmaTheme.Radius.xl, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: DharmaTheme.Radius.xl, style: .continuous)
                .stroke(Color.black.opacity(0.05), lineWidth: 1)
        }
        .fixedSize(horizontal: true, vertical: false)
    }

    private var notificationsStep: some View {
        VStack(spacing: DharmaTheme.Spacing.xxxl) {
            VStack(spacing: DharmaTheme.Spacing.lg) {
                Text("Dharma keeps you consistent through routine notifications")
                    .font(DharmaTheme.Typography.scriptureHeadline(34))
                    .foregroundColor(DharmaTheme.Colors.onSurface)
                    .multilineTextAlignment(.center)

                Text("A gentle reminder for your verse, practice, and reflection helps your ritual stay steady even on busy days.")
                    .font(DharmaTheme.Typography.uiBody(16))
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.top, 72)

            notificationPromptCard

            Text("We only use notifications for your daily Dharma routine. You can change this any time in Settings.")
                .font(DharmaTheme.Typography.uiCaption(13))
                .foregroundColor(DharmaTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
    }

    private var widgetsStep: some View {
        VStack(spacing: DharmaTheme.Spacing.xxxl) {
            VStack(spacing: DharmaTheme.Spacing.lg) {
                Text("Dharma Brings Spirituality to your Home Screen")
                    .font(DharmaTheme.Typography.scriptureHeadline(34))
                    .foregroundColor(DharmaTheme.Colors.onSurface)
                    .multilineTextAlignment(.center)

                Text("Stay consistent with your daily verses as widgets, all part of your personalized spirituality plan!")
                    .font(DharmaTheme.Typography.uiBody(16))
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.top, 72)

            widgetPreviewCard
        }
        .frame(maxWidth: .infinity)
    }

    private var notificationPromptCard: some View {
        VStack(spacing: 0) {
            VStack(spacing: DharmaTheme.Spacing.md) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(DharmaTheme.Colors.saffron)
                    .frame(width: 56, height: 56)
                    .background(DharmaTheme.Colors.saffron.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: DharmaTheme.Radius.lg, style: .continuous))

                Text("Dharma would like to send you notifications")
                    .font(DharmaTheme.Typography.uiHeadline(20))
                    .foregroundColor(DharmaTheme.Colors.onSurface)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
            .padding(.horizontal, DharmaTheme.Spacing.xl)
            .padding(.vertical, DharmaTheme.Spacing.xxl)
            .frame(maxWidth: .infinity)
            .background(DharmaTheme.Colors.surfaceContainerLowest.opacity(0.98))

            HStack(spacing: 0) {
                Text("Don't Allow")
                    .font(DharmaTheme.Typography.uiBody(16))
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DharmaTheme.Spacing.lg)
                    .background(Color.black.opacity(0.04))

                Text("Allow")
                    .font(DharmaTheme.Typography.uiHeadline(16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DharmaTheme.Spacing.lg)
                    .background(DharmaTheme.Colors.saffron)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.08), radius: 28, x: 0, y: 16)
        .padding(.horizontal, DharmaTheme.Spacing.md)
    }

    private var widgetPreviewCard: some View {
        VStack(alignment: .leading, spacing: DharmaTheme.Spacing.lg) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: DharmaTheme.Spacing.xs) {
                    Text("Daily Verse")
                        .font(DharmaTheme.Typography.uiCaption(12))
                        .foregroundColor(DharmaTheme.Colors.saffronDark)

                    Text("Truth is one; the wise call it by many names.")
                        .font(DharmaTheme.Typography.scriptureHeadline(22))
                        .foregroundColor(DharmaTheme.Colors.onSurface)
                        .lineSpacing(4)
                }

                Spacer()

                Image(systemName: "sparkles.rectangle.stack.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(DharmaTheme.Colors.saffron)
            }

            Text("A calm reminder from your practice, right on the Home Screen.")
                .font(DharmaTheme.Typography.uiBody(15))
                .foregroundColor(DharmaTheme.Colors.secondaryText)
                .lineSpacing(4)

            HStack(spacing: DharmaTheme.Spacing.sm) {
                Label("Daily verse", systemImage: "sun.max.fill")
                Label("One-tap reflection", systemImage: "hand.tap.fill")
            }
            .font(DharmaTheme.Typography.uiCaption(13))
            .foregroundColor(DharmaTheme.Colors.onSurfaceVariant)
        }
        .padding(DharmaTheme.Spacing.xl)
        .background(
            LinearGradient(
                colors: [
                    DharmaTheme.Colors.surfaceContainerLowest.opacity(0.98),
                    DharmaTheme.Colors.cardHindu.opacity(0.85)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.black.opacity(0.06), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.08), radius: 28, x: 0, y: 16)
        .padding(.horizontal, DharmaTheme.Spacing.md)
    }

    private var generatingStep: some View {
        VStack(spacing: DharmaTheme.Spacing.xl) {
            VStack(spacing: DharmaTheme.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(DharmaTheme.Colors.saffron.opacity(0.12))
                        .frame(width: 120, height: 120)

                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(DharmaTheme.Colors.saffron)
                }

                Text(viewModel.loadingMessages[viewModel.loadingMessageIndex])
                    .font(DharmaTheme.Typography.scriptureHeadline(26))
                    .foregroundColor(DharmaTheme.Colors.onSurface)
                    .multilineTextAlignment(.center)

                Text("Shaping your daily rhythm.")
                    .font(DharmaTheme.Typography.uiBody(16))
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.top, 120)

            infoCard(
                title: "Fun fact",
                body: "The Bhagavad Gita contains 700 verses spoken over a single day on the battlefield of Kurukshetra."
            )
        }
    }

    private func stepLayout<Content: View>(eyebrow: String, title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DharmaTheme.Spacing.xl) {
            VStack(alignment: .leading, spacing: DharmaTheme.Spacing.md) {
                Text(eyebrow.uppercased())
                    .font(DharmaTheme.Typography.uiLabel(12))
                    .kerning(1.2)
                    .foregroundColor(DharmaTheme.Colors.saffronDark)

                Text(title)
                    .font(DharmaTheme.Typography.scriptureHeadline(32))
                    .foregroundColor(DharmaTheme.Colors.onSurface)

                if let subtitle {
                    Text(subtitle)
                        .font(DharmaTheme.Typography.uiBody(16))
                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                        .lineSpacing(4)
                }
            }

            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func introCard(symbol: String, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: DharmaTheme.Spacing.md) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(DharmaTheme.Colors.saffron)
                .frame(width: 46, height: 46)
                .background(DharmaTheme.Colors.saffron.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: DharmaTheme.Radius.md, style: .continuous))

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
        .background(DharmaTheme.Colors.surfaceContainerLowest.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: DharmaTheme.Radius.lg, style: .continuous))
    }

    private func infoCard(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: DharmaTheme.Spacing.sm) {
            Text(title)
                .font(DharmaTheme.Typography.uiHeadline(16))
                .foregroundColor(DharmaTheme.Colors.onSurface)

            Text(body)
                .font(DharmaTheme.Typography.uiBody(15))
                .foregroundColor(DharmaTheme.Colors.secondaryText)
                .lineSpacing(4)
        }
        .padding(DharmaTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DharmaTheme.Colors.surfaceContainerLowest.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: DharmaTheme.Radius.lg, style: .continuous))
    }

    private func statisticCard(value: String, label: String) -> some View {
        HStack(alignment: .center, spacing: DharmaTheme.Spacing.lg) {
            Text(value)
                .font(DharmaTheme.Typography.scriptureHeadline(28))
                .foregroundColor(DharmaTheme.Colors.saffronDark)

            Text(label)
                .font(DharmaTheme.Typography.uiBody(15))
                .foregroundColor(DharmaTheme.Colors.secondaryText)

            Spacer()
        }
        .padding(DharmaTheme.Spacing.lg)
        .background(DharmaTheme.Colors.surfaceContainerLowest.opacity(0.94))
        .clipShape(RoundedRectangle(cornerRadius: DharmaTheme.Radius.lg, style: .continuous))
    }

    private func socialQuote(_ quote: String) -> some View {
        VStack(alignment: .leading, spacing: DharmaTheme.Spacing.sm) {
            Text("\"\(quote)\"")
                .font(DharmaTheme.Typography.uiBody(16))
                .foregroundColor(DharmaTheme.Colors.onSurface)
                .lineSpacing(4)

            Text("Early Dharma user")
                .font(DharmaTheme.Typography.uiCaption())
                .foregroundColor(DharmaTheme.Colors.secondaryText)
        }
        .padding(DharmaTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DharmaTheme.Colors.cardHindu.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: DharmaTheme.Radius.lg, style: .continuous))
    }

    private func optionList<Item: Identifiable>(
        items: [Item],
        selectionContains: @escaping (Item) -> Bool,
        title: KeyPath<Item, String>,
        action: @escaping (Item) -> Void
    ) -> some View {
        VStack(spacing: DharmaTheme.Spacing.md) {
            ForEach(items) { item in
                Button {
                    action(item)
                } label: {
                    HStack(alignment: .top, spacing: DharmaTheme.Spacing.md) {
                        VStack(alignment: .leading, spacing: DharmaTheme.Spacing.xs) {
                            Text(item[keyPath: title])
                                .font(DharmaTheme.Typography.uiHeadline(16))
                                .foregroundColor(DharmaTheme.Colors.onSurface)
                                .multilineTextAlignment(.leading)
                        }

                        Spacer()

                        Image(systemName: selectionContains(item) ? "checkmark.circle.fill" : "circle")
                            .font(.system(size: 21, weight: .medium))
                            .foregroundColor(selectionContains(item) ? DharmaTheme.Colors.saffron : DharmaTheme.Colors.outlineVariant)
                    }
                    .padding(DharmaTheme.Spacing.lg)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(DharmaTheme.Colors.surfaceContainerLowest.opacity(0.94))
                    .overlay {
                        RoundedRectangle(cornerRadius: DharmaTheme.Radius.lg, style: .continuous)
                            .stroke(
                                selectionContains(item) ? DharmaTheme.Colors.saffron : Color.clear,
                                lineWidth: 2
                            )
                    }
                    .clipShape(RoundedRectangle(cornerRadius: DharmaTheme.Radius.lg, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    OnboardingView(
        viewModel: OnboardingViewModel(),
        superwallViewModel: SuperwallViewModel.shared,
        authViewModel: AuthViewModel()
    )
}
