import SwiftUI

struct GratitudeJournalView: View {
    let onDone: () -> Void
    @State private var viewModel = GratitudeJournalViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: DharmaTheme.Spacing.xl) {
                    // Header
                    VStack(spacing: DharmaTheme.Spacing.sm) {
                        Text("🙏")
                            .font(.system(size: 48))
                        
                        Text("Gratitude Journal")
                            .font(DharmaTheme.Typography.scriptureHeadline(24))
                            .foregroundColor(DharmaTheme.Colors.onSurface)
                        
                        Text(viewModel.todayFormatted)
                            .font(DharmaTheme.Typography.uiCaption())
                            .foregroundColor(DharmaTheme.Colors.secondaryText)
                    }
                    .padding(.top, DharmaTheme.Spacing.xl)

                    if let errorMessage = viewModel.errorMessage {
                        statusCard(
                            text: errorMessage,
                            background: DharmaTheme.Colors.cardJournal.opacity(0.45),
                            foreground: DharmaTheme.Colors.onSurface
                        )
                    }

                    if let saveMessage = viewModel.saveMessage {
                        statusCard(
                            text: saveMessage,
                            background: DharmaTheme.Colors.cardBuddhist.opacity(0.45),
                            foreground: DharmaTheme.Colors.onSurface
                        )
                    }
                    
                    // Prompt
                    VStack(alignment: .leading, spacing: DharmaTheme.Spacing.md) {
                        Text("What are you grateful for today?")
                            .font(DharmaTheme.Typography.uiHeadline(16))
                            .foregroundColor(DharmaTheme.Colors.onSurface)
                        
                        Text("Take a moment to reflect on the blessings in your life. Even the smallest things deserve recognition.")
                            .font(DharmaTheme.Typography.uiBody(14))
                            .foregroundColor(DharmaTheme.Colors.secondaryText)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DharmaTheme.Spacing.sm)
                    
                    // Text editor
                    VStack(alignment: .leading, spacing: DharmaTheme.Spacing.sm) {
                        TextEditor(text: $viewModel.gratitudeText)
                            .font(DharmaTheme.Typography.scriptureBody(17))
                            .lineSpacing(6)
                            .frame(minHeight: 200)
                            .padding(DharmaTheme.Spacing.lg)
                            .background(DharmaTheme.Colors.surface)
                            .cornerRadius(DharmaTheme.Radius.lg)
                            .scrollContentBackground(.hidden)
                            .overlay(alignment: .topLeading) {
                                if viewModel.gratitudeText.isEmpty {
                                    Text("Write a few lines about today's blessings...")
                                        .font(DharmaTheme.Typography.scriptureBody(17))
                                        .foregroundColor(DharmaTheme.Colors.secondaryText.opacity(0.8))
                                        .padding(.horizontal, DharmaTheme.Spacing.xl)
                                        .padding(.vertical, DharmaTheme.Spacing.xl)
                                        .allowsHitTesting(false)
                                }
                            }
                            .disabled(viewModel.isLoading || viewModel.isSaving)
                        
                        if viewModel.isLoading {
                            HStack(spacing: DharmaTheme.Spacing.sm) {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Loading your saved reflections...")
                                    .font(DharmaTheme.Typography.uiCaption(11))
                                    .foregroundColor(DharmaTheme.Colors.secondaryText)
                            }
                            .padding(.leading, DharmaTheme.Spacing.sm)
                        } else if !viewModel.gratitudeText.isEmpty {
                            Text("\(viewModel.gratitudeText.count) characters")
                                .font(DharmaTheme.Typography.uiCaption(11))
                                .foregroundColor(DharmaTheme.Colors.secondaryText)
                                .padding(.leading, DharmaTheme.Spacing.sm)
                        }
                    }
                    
                    // Inspiration suggestions
                    VStack(alignment: .leading, spacing: DharmaTheme.Spacing.md) {
                        Text("Need inspiration?")
                            .font(DharmaTheme.Typography.uiCaption())
                            .foregroundColor(DharmaTheme.Colors.secondaryText)
                        
                        FlowLayout(spacing: DharmaTheme.Spacing.sm) {
                            promptChip("A person who helped me")
                            promptChip("A moment of peace")
                            promptChip("Something I learned")
                            promptChip("A simple pleasure")
                            promptChip("My health")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, DharmaTheme.Spacing.sm)
                    
                    // Previous entries (if any)
                    if !viewModel.previousEntries.isEmpty {
                        VStack(alignment: .leading, spacing: DharmaTheme.Spacing.md) {
                            Text("Previous entries")
                                .font(DharmaTheme.Typography.uiCaption())
                                .foregroundColor(DharmaTheme.Colors.secondaryText)
                            
                            ForEach(viewModel.previousEntries) { entry in
                                VStack(alignment: .leading, spacing: DharmaTheme.Spacing.xs) {
                                    Text(entry.displayDate)
                                        .font(DharmaTheme.Typography.uiCaption(12))
                                        .foregroundColor(DharmaTheme.Colors.secondaryText)

                                    Text(entry.content)
                                        .font(DharmaTheme.Typography.uiBody(14))
                                        .foregroundColor(DharmaTheme.Colors.onSurface)
                                        .lineSpacing(4)
                                }
                                .padding(DharmaTheme.Spacing.md)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(DharmaTheme.Colors.surface)
                                .cornerRadius(DharmaTheme.Radius.md)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, DharmaTheme.Spacing.sm)
                    }
                }
                .padding(.horizontal, DharmaTheme.Spacing.lg)
                .padding(.bottom, 100) // Space for bottom bar
            }
            .background(Color.white)
            .safeAreaInset(edge: .bottom) {
                HStack {
                    Spacer()
                    Button(viewModel.saveButtonTitle) {
                        Task {
                            let didSave = await viewModel.saveEntry()
                            if didSave {
                                onDone()
                            }
                        }
                    }
                    .buttonStyle(.saffron)
                    .disabled(!viewModel.hasText || viewModel.isLoading || viewModel.isSaving)
                    Spacer()
                }
                .padding(.vertical, DharmaTheme.Spacing.md)
                .background(
                    Color.white
                        .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: -4)
                )
            }
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
        .task {
            await viewModel.loadEntries()
        }
    }
    
    private func promptChip(_ text: String) -> some View {
        Button {
            if viewModel.gratitudeText.isEmpty {
                viewModel.gratitudeText = text + "... "
            } else {
                viewModel.gratitudeText += "\n" + text + "... "
            }
        } label: {
            Text(text)
                .font(DharmaTheme.Typography.uiCaption(12))
                .foregroundColor(DharmaTheme.Colors.onSurfaceVariant)
                .padding(.horizontal, DharmaTheme.Spacing.md)
                .padding(.vertical, DharmaTheme.Spacing.sm)
                .background(DharmaTheme.Colors.surface)
                .cornerRadius(DharmaTheme.Radius.xl)
        }
        .disabled(viewModel.isLoading || viewModel.isSaving)
    }

    private func statusCard(text: String, background: Color, foreground: Color) -> some View {
        Text(text)
            .font(DharmaTheme.Typography.uiBody(14))
            .foregroundColor(foreground)
            .padding(DharmaTheme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(background)
            .cornerRadius(DharmaTheme.Radius.md)
    }
}

// MARK: - Simple Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = computeLayout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }
    
    private func computeLayout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }
        
        let totalHeight = currentY + lineHeight
        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}

#Preview {
    GratitudeJournalView(onDone: {})
}
