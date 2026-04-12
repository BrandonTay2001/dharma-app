import SwiftUI

struct MantraView: View {
    private enum TraditionFilter: String, CaseIterable, Identifiable {
        case hindu
        case buddhist

        var id: String { rawValue }

        var title: String {
            switch self {
            case .hindu:
                return "Hindu"
            case .buddhist:
                return "Buddhist"
            }
        }

        var symbol: String {
            switch self {
            case .hindu:
                return "🕉️"
            case .buddhist:
                return "☸️"
            }
        }
    }

    let onDone: () -> Void
    @State private var beadCount: Int = 0
    @State private var isChanting = false
    @State private var selectedTradition: TraditionFilter = .hindu
    @State private var currentMantraIndex = 0
    @State private var showMilestone = false

    private let minimumReps = 3
    @Environment(\.dismiss) private var dismiss

    private let totalBeads = 27 // Quarter mala

    private let mantrasByTradition: [TraditionFilter: [(sanskrit: String, translation: String, meaning: String)]] = [
        .hindu: [
            (
                "ॐ नमः शिवाय",
                "Om Namah Shivaya",
                "I bow to Shiva, the supreme deity of transformation."
            ),
            (
                "हरे कृष्ण हरे राम",
                "Hare Krishna Hare Rama",
                "A mantra invoking the divine energy and joy."
            ),
            (
                "ॐ गं गणपतये नमः",
                "Om Gam Ganapataye Namaha",
                "Salutations to Ganesha, remover of obstacles."
            )
        ],
        .buddhist: [
            (
                "ॐ मणि पद्मे हूँ",
                "Om Mani Padme Hum",
                "Hail to the jewel in the lotus. A mantra of compassion."
            ),
            (
                "ॐ अमिदेव ह्रीः",
                "Om Amideva Hrih",
                "Invocation of Amitabha, the Buddha of Infinite Light."
            ),
            (
                "ॐ तारे तुत्तारे तुरे स्वाहा",
                "Om Tare Tuttare Ture Svaha",
                "Prayer to Green Tara, the mother of liberation."
            )
        ]
    ]

    private var currentMantras: [(sanskrit: String, translation: String, meaning: String)] {
        mantrasByTradition[selectedTradition] ?? []
    }

    private var currentMantra: (sanskrit: String, translation: String, meaning: String) {
        currentMantras[currentMantraIndex % currentMantras.count]
    }

    private var canAdvanceToNextMantra: Bool {
        currentMantraIndex < currentMantras.count - 1
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: DharmaTheme.Spacing.xxl) {
                Spacer()

                Text(selectedTradition.symbol)
                    .font(.system(size: 64))
                    .scaleEffect(isChanting ? 1.1 : 1.0)
                    .animation(
                        .easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                        value: isChanting
                    )
                
                // Sanskrit text
                Text(currentMantra.sanskrit)
                    .font(DharmaTheme.Typography.scriptureDisplay(36))
                    .foregroundColor(DharmaTheme.Colors.onSurface)
                    .multilineTextAlignment(.center)
                
                // Transliteration
                Text(currentMantra.translation)
                    .font(DharmaTheme.Typography.scriptureBody(18))
                    .foregroundColor(DharmaTheme.Colors.saffron)
                
                // Meaning
                Text(currentMantra.meaning)
                    .font(DharmaTheme.Typography.uiBody(14))
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DharmaTheme.Spacing.xxl)
                
                Spacer()

                // Bead counter
                VStack(spacing: DharmaTheme.Spacing.md) {
                    Text("\(beadCount) / \(totalBeads)")
                        .font(DharmaTheme.Typography.uiTitle(28))
                        .foregroundColor(DharmaTheme.Colors.onSurface)
                    
                    Text("repetitions")
                        .font(DharmaTheme.Typography.uiCaption())
                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                    
                    // Milestone hint
                    if showMilestone {
                        Text("\(minimumReps) recitations reached, feel free to proceed")
                            .font(DharmaTheme.Typography.uiCaption(12))
                            .foregroundColor(DharmaTheme.Colors.saffron)
                            .transition(.opacity.combined(with: .scale))
                    }

                    // Progress ring
                    ZStack {
                        Circle()
                            .stroke(DharmaTheme.Colors.surfaceContainerLow, lineWidth: 4)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(beadCount) / CGFloat(totalBeads))
                            .stroke(DharmaTheme.Colors.saffron, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .shadow(color: showMilestone ? DharmaTheme.Colors.saffron.opacity(0.5) : .clear, radius: showMilestone ? 10 : 0)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.3), value: beadCount)
                        
                        // Tap target
                        Button {
                            if beadCount < totalBeads {
                                beadCount += 1
                                isChanting = true

                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()

                                if beadCount == minimumReps {
                                    triggerMilestone()
                                }
                            }
                        } label: {
                            Text("📿")
                                .font(.system(size: 32))
                        }
                    }
                }

                Spacer()

                // Done / Next mantra buttons
                HStack(spacing: DharmaTheme.Spacing.lg) {
                    Button {
                        advanceToNextMantra()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.right.circle")
                            Text("Next Mantra")
                        }
                    }
                    .buttonStyle(.ghost)
                    .disabled(!canAdvanceToNextMantra)
                    .opacity(canAdvanceToNextMantra ? 1 : 0.45)
                    
                    Button("Done") {
                        onDone()
                    }
                    .buttonStyle(.saffron)
                }
                .padding(.bottom, DharmaTheme.Spacing.xxl)
            }
            .background(Color.white)
            .navigationTitle("Daily Mantra")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(TraditionFilter.allCases) { tradition in
                            Button {
                                selectTradition(tradition)
                            } label: {
                                if tradition == selectedTradition {
                                    Label(tradition.title, systemImage: "checkmark")
                                } else {
                                    Text(tradition.title)
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(selectedTradition.title)
                                .font(DharmaTheme.Typography.uiCaption())
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .foregroundColor(DharmaTheme.Colors.onSurface)
                        .padding(.horizontal, DharmaTheme.Spacing.md)
                        .padding(.vertical, DharmaTheme.Spacing.sm)
                        .background(DharmaTheme.Colors.surface)
                        .cornerRadius(DharmaTheme.Radius.xl)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(DharmaTheme.Colors.onSurface)
                    }
                }
            }
        }
    }

    private func selectTradition(_ tradition: TraditionFilter) {
        guard selectedTradition != tradition else { return }
        selectedTradition = tradition
        resetPracticeState()
    }

    private func advanceToNextMantra() {
        guard canAdvanceToNextMantra else { return }
        currentMantraIndex += 1
        beadCount = 0
        isChanting = false
        showMilestone = false
    }

    private func resetPracticeState() {
        currentMantraIndex = 0
        beadCount = 0
        isChanting = false
        showMilestone = false
    }

    private func triggerMilestone() {
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)

        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            showMilestone = true
        }
    }
}

#Preview {
    MantraView(onDone: {})
}
