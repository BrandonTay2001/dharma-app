import SwiftUI

struct MantraView: View {
    let onDone: () -> Void
    @State private var beadCount: Int = 0
    @State private var isChanting = false
    @Environment(\.dismiss) private var dismiss
    
    private let totalBeads = 27 // Quarter mala
    
    private let mantras: [(sanskrit: String, translation: String, meaning: String)] = [
        (
            "ॐ नमः शिवाय",
            "Om Namah Shivaya",
            "I bow to Shiva, the supreme deity of transformation."
        ),
        (
            "ॐ मणि पद्मे हूँ",
            "Om Mani Padme Hum",
            "Hail to the jewel in the lotus. A mantra of compassion."
        ),
        (
            "हरे कृष्ण हरे राम",
            "Hare Krishna Hare Rama",
            "A mantra invoking the divine energy and joy."
        ),
    ]
    
    @State private var currentMantraIndex = 0
    
    private var currentMantra: (sanskrit: String, translation: String, meaning: String) {
        mantras[currentMantraIndex % mantras.count]
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: DharmaTheme.Spacing.xxl) {
                Spacer()
                
                // Om symbol
                Text("🕉️")
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
                    
                    // Progress ring
                    ZStack {
                        Circle()
                            .stroke(DharmaTheme.Colors.surfaceContainerLow, lineWidth: 4)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(beadCount) / CGFloat(totalBeads))
                            .stroke(DharmaTheme.Colors.saffron, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                            .animation(.easeInOut(duration: 0.3), value: beadCount)
                        
                        // Tap target
                        Button {
                            if beadCount < totalBeads {
                                beadCount += 1
                                isChanting = true
                                
                                // Light haptic
                                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                                impactFeedback.impactOccurred()
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
                        currentMantraIndex += 1
                        beadCount = 0
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.right.circle")
                            Text("Next Mantra")
                        }
                    }
                    .buttonStyle(.ghost)
                    
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
}

#Preview {
    MantraView(onDone: {})
}
