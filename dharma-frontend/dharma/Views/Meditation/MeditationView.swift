import SwiftUI

struct MeditationView: View {
    let onDone: () -> Void
    @State private var viewModel = MeditationViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button {
                    viewModel.stopSession()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(DharmaTheme.Colors.saffron)
                        .frame(width: 40, height: 40)
                        .background(DharmaTheme.Colors.surface)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                Text("Meditation Session")
                    .font(DharmaTheme.Typography.uiHeadline(16))
                    .foregroundColor(DharmaTheme.Colors.saffron)
                
                Spacer()
                
                // Invisible spacer for balance
                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.horizontal, DharmaTheme.Spacing.lg)
            .padding(.top, DharmaTheme.Spacing.lg)
            
            // Step progress indicator
            stepIndicator
                .padding(.top, DharmaTheme.Spacing.xl)
            
            Spacer()
            
            // Main breathing content
            if viewModel.isSessionComplete {
                completionView
            } else if viewModel.isActive {
                breathingView
            } else {
                startView
            }
            
            Spacer()
            
            // Timer & Done button
            VStack(spacing: DharmaTheme.Spacing.xl) {
                if viewModel.isActive {
                    Text(viewModel.timeRemainingText)
                        .font(DharmaTheme.Typography.uiTitle(20))
                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                }
                
                if viewModel.isSessionComplete {
                    Button("Done") {
                        onDone()
                    }
                    .buttonStyle(.saffron)
                } else if !viewModel.isActive {
                    Button("Begin") {
                        viewModel.startSession()
                    }
                    .buttonStyle(.saffron)
                } else {
                    Button("End Session") {
                        viewModel.completeSession()
                    }
                    .buttonStyle(.ghost)
                }
            }
            .padding(.bottom, DharmaTheme.Spacing.xxxl)
        }
        .background(Color.white)
    }
    
    // MARK: - Step Indicator
    private var stepIndicator: some View {
        HStack(spacing: DharmaTheme.Spacing.md) {
            ForEach(0..<viewModel.steps.count, id: \.self) { index in
                Circle()
                    .fill(
                        index <= (viewModel.currentStepIndex % viewModel.steps.count)
                            ? DharmaTheme.Colors.saffron
                            : DharmaTheme.Colors.surfaceContainer
                    )
                    .frame(width: 10, height: 10)
                
                if index < viewModel.steps.count - 1 {
                    Rectangle()
                        .fill(
                            index < (viewModel.currentStepIndex % viewModel.steps.count)
                                ? DharmaTheme.Colors.saffron
                                : DharmaTheme.Colors.surfaceContainer
                        )
                        .frame(height: 2)
                }
            }
        }
        .padding(.horizontal, DharmaTheme.Spacing.xxxl)
    }
    
    // MARK: - Breathing View
    private var breathingView: some View {
        VStack(spacing: DharmaTheme.Spacing.xxxl) {
            // Instruction text
            Text(viewModel.currentInstruction)
                .font(DharmaTheme.Typography.scriptureHeadline(28))
                .foregroundColor(DharmaTheme.Colors.saffron)
                .multilineTextAlignment(.center)
                .animation(.easeInOut(duration: 0.5), value: viewModel.currentInstruction)
            
            // Breathing orb with lotus
            ZStack {
                // Outer glow rings
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .fill(DharmaTheme.Colors.saffron.opacity(0.06 - Double(i) * 0.015))
                        .frame(
                            width: CGFloat(120 + i * 40) * viewModel.breathingScale,
                            height: CGFloat(120 + i * 40) * viewModel.breathingScale
                        )
                        .animation(.easeInOut(duration: 0.5), value: viewModel.breathingScale)
                }
                
                // Center orb
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                DharmaTheme.Colors.saffron.opacity(0.3),
                                DharmaTheme.Colors.saffron.opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 10,
                            endRadius: 60
                        )
                    )
                    .frame(width: 80 * viewModel.breathingScale, height: 80 * viewModel.breathingScale)
                    .animation(.easeInOut(duration: 0.5), value: viewModel.breathingScale)
                
                // Lotus emoji
                Text("🪷")
                    .font(.system(size: 40 * viewModel.breathingScale))
                    .animation(.easeInOut(duration: 0.5), value: viewModel.breathingScale)
            }
        }
    }
    
    // MARK: - Start View
    private var startView: some View {
        VStack(spacing: DharmaTheme.Spacing.xxl) {
            Text("🪷")
                .font(.system(size: 64))
            
            Text("Find Your Peace")
                .font(DharmaTheme.Typography.scriptureHeadline(28))
                .foregroundColor(DharmaTheme.Colors.onSurface)
            
            Text("3 minute guided breathing session")
                .font(DharmaTheme.Typography.uiBody(16))
                .foregroundColor(DharmaTheme.Colors.secondaryText)
        }
    }
    
    // MARK: - Completion View
    private var completionView: some View {
        VStack(spacing: DharmaTheme.Spacing.xxl) {
            Text("🙏")
                .font(.system(size: 64))
            
            Text("Session Complete")
                .font(DharmaTheme.Typography.scriptureHeadline(28))
                .foregroundColor(DharmaTheme.Colors.saffron)
            
            Text("May peace be with you.\nOm Shanti, Shanti, Shanti.")
                .font(DharmaTheme.Typography.scriptureBody(18))
                .foregroundColor(DharmaTheme.Colors.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
        }
    }
}

#Preview {
    MeditationView(onDone: {})
}
