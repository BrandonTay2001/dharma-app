import SwiftUI
import UIKit

struct DailyVerseDetailView: View {
    let verseType: DailyTask.TaskType
    let onDone: () -> Void
    let onChatToLearnMore: () -> Void
    @State private var showReflection = false
    @State private var viewModel: DailyVerseReflectionViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    init(verseType: DailyTask.TaskType, onDone: @escaping () -> Void, onChatToLearnMore: @escaping () -> Void) {
        self.verseType = verseType
        self.onDone = onDone
        self.onChatToLearnMore = onChatToLearnMore

        let viewModel = DailyVerseReflectionViewModel(verseType: verseType)
        _viewModel = State(initialValue: viewModel)
        _showReflection = State(initialValue: viewModel.hasReflection)
    }
    
    var body: some View {
        @Bindable var viewModel = viewModel

        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DharmaTheme.Spacing.xxl) {
                        // Verse Card
                        VStack(spacing: DharmaTheme.Spacing.xl) {
                            // Lotus icon
                            Text("🪷")
                                .font(.system(size: 48))
                                .padding(.top, DharmaTheme.Spacing.xxl)
                            
                            // Label
                            Text(verseType.verseTitle)
                                .font(DharmaTheme.Typography.uiLabel(13))
                                .foregroundColor(DharmaTheme.Colors.saffron)
                                .tracking(1.5)
                            
                            // Verse text
                            Text(verseType.verseText)
                                .font(DharmaTheme.Typography.scriptureBody(20))
                                .foregroundColor(DharmaTheme.Colors.onSurface)
                                .multilineTextAlignment(.center)
                                .lineSpacing(8)
                                .padding(.horizontal, DharmaTheme.Spacing.lg)
                                .padding(.bottom, DharmaTheme.Spacing.xxl)
                        }
                        .frame(maxWidth: .infinity)
                        .background(DharmaTheme.Colors.surface)
                        .cornerRadius(DharmaTheme.Radius.lg)
                        .padding(.horizontal, DharmaTheme.Spacing.sm)
                        
                        // Reflection area
                        if showReflection {
                            VStack(alignment: .leading, spacing: DharmaTheme.Spacing.sm) {
                                Text("Your Reflection")
                                    .font(DharmaTheme.Typography.uiHeadline(16))
                                    .foregroundColor(DharmaTheme.Colors.onSurface)
                                
                                TextEditor(text: $viewModel.reflectionText)
                                    .font(DharmaTheme.Typography.uiBody())
                                    .foregroundColor(DharmaTheme.Colors.onSurface)
                                    .tint(DharmaTheme.Colors.saffron)
                                    .frame(minHeight: 100)
                                    .padding(DharmaTheme.Spacing.sm)
                                    .background(DharmaTheme.Colors.surface)
                                    .cornerRadius(DharmaTheme.Radius.md)
                                    .scrollContentBackground(.hidden)

                                HStack {
                                    Text(viewModel.storageHint)
                                        .font(DharmaTheme.Typography.uiCaption(11))
                                        .foregroundColor(DharmaTheme.Colors.secondaryText)

                                    Spacer()

                                    Text("\(viewModel.characterCount) characters")
                                        .font(DharmaTheme.Typography.uiCaption(11))
                                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                                }
                            }
                            .padding(.horizontal, DharmaTheme.Spacing.sm)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                    }
                    .padding(.top, DharmaTheme.Spacing.lg)
                }
                
                // Bottom action bar
                HStack(spacing: DharmaTheme.Spacing.sm) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showReflection.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil.circle")
                                .font(.system(size: 16))
                            Text(viewModel.hasReflection ? "Edit reflection" : "Reflection")
                                .font(DharmaTheme.Typography.uiCaption())
                        }
                    }
                    .buttonStyle(.ghost)
                    
                    Button {
                        onChatToLearnMore()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.left.fill")
                                .font(.system(size: 14))
                            Text("Chat to learn more")
                                .font(DharmaTheme.Typography.uiCaption())
                        }
                    }
                    .buttonStyle(.ghost)
                    
                    Spacer()
                    
                    Button("Done") {
                        onDone()
                    }
                    .buttonStyle(.saffron)
                }
                .padding(.horizontal, DharmaTheme.Spacing.lg)
                .padding(.vertical, DharmaTheme.Spacing.md)
                .background(
                    Color.white
                        .shadow(color: .black.opacity(0.04), radius: 16, x: 0, y: -4)
                )
            }
            .background(Color.white)
            .navigationTitle("Your Journey")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                            .foregroundColor(DharmaTheme.Colors.onSurface)
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
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            viewModel.loadReflection()
            showReflection = viewModel.hasReflection
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            viewModel.loadReflection()
            showReflection = viewModel.hasReflection
        }
    }
}

#Preview {
    DailyVerseDetailView(verseType: .hinduVerse, onDone: {}, onChatToLearnMore: {})
}
