import SwiftUI

struct LearnView: View {
    private let topics: [(emoji: String, title: String, subtitle: String, color: Color)] = [
        ("☸️", "Four Noble Truths", "Buddhist Foundation", DharmaTheme.Colors.cardBuddhist),
        ("🔥", "Karma & Dharma", "Hindu Philosophy", DharmaTheme.Colors.cardHindu),
        ("🧘", "Meditation Basics", "Mindfulness Practice", DharmaTheme.Colors.cardMeditation),
        ("🪷", "Noble Eightfold Path", "Buddhist Practice", DharmaTheme.Colors.cardBuddhist),
        ("📖", "The Upanishads", "Vedic Wisdom", DharmaTheme.Colors.cardMantra),
        ("🙏", "Yoga Philosophy", "Union of Mind & Spirit", DharmaTheme.Colors.cardGratitude),
        ("🕉️", "Mantra & Chanting", "Sacred Sounds", DharmaTheme.Colors.cardMantra),
        ("💎", "Zen Buddhism", "The Way of Zen", DharmaTheme.Colors.cardBuddhist),
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DharmaTheme.Spacing.xl) {
                    // Header
                    VStack(spacing: DharmaTheme.Spacing.sm) {
                        Text("Learn")
                            .font(DharmaTheme.Typography.scriptureHeadline(28))
                            .foregroundColor(DharmaTheme.Colors.onSurface)
                        
                        Text("Deepen your spiritual understanding")
                            .font(DharmaTheme.Typography.uiBody(14))
                            .foregroundColor(DharmaTheme.Colors.secondaryText)
                    }
                    .padding(.top, DharmaTheme.Spacing.xl)
                    
                    // Topic cards
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: DharmaTheme.Spacing.md),
                            GridItem(.flexible(), spacing: DharmaTheme.Spacing.md)
                        ],
                        spacing: DharmaTheme.Spacing.md
                    ) {
                        ForEach(Array(topics.enumerated()), id: \.offset) { _, topic in
                            topicCard(topic)
                        }
                    }
                    
                    // Coming soon note
                    VStack(spacing: DharmaTheme.Spacing.sm) {
                        Text("More teachings coming soon")
                            .font(DharmaTheme.Typography.uiCaption())
                            .foregroundColor(DharmaTheme.Colors.secondaryText)
                        
                        Text("We're curating wisdom from authentic sources")
                            .font(DharmaTheme.Typography.uiCaption(11))
                            .foregroundColor(DharmaTheme.Colors.secondaryText.opacity(0.7))
                    }
                    .padding(.top, DharmaTheme.Spacing.lg)
                }
                .padding(.horizontal, DharmaTheme.Spacing.lg)
                .padding(.bottom, DharmaTheme.Spacing.xxxl)
            }
            .background(Color.white)
        }
    }
    
    private func topicCard(_ topic: (emoji: String, title: String, subtitle: String, color: Color)) -> some View {
        VStack(spacing: DharmaTheme.Spacing.md) {
            Text(topic.emoji)
                .font(.system(size: 36))
                .padding(.top, DharmaTheme.Spacing.lg)
            
            VStack(spacing: 4) {
                Text(topic.title)
                    .font(DharmaTheme.Typography.uiLabel(12))
                    .foregroundColor(DharmaTheme.Colors.onSurface)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                Text(topic.subtitle)
                    .font(DharmaTheme.Typography.uiCaption(11))
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(topic.color)
        .cornerRadius(DharmaTheme.Radius.lg)
    }
}

#Preview {
    LearnView()
}
