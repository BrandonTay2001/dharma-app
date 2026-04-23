import SwiftUI
import UIKit
#if canImport(WidgetKit)
import WidgetKit
#endif

struct DailyVerseDetailView: View {
    @Bindable var viewModel: DailyVerseViewModel
    let onDone: () -> Void
    let onChatToLearnMore: (DailyVerse) -> Void
    @State private var showReflection = false
    @State private var showWidgetInstructions = false
    @State private var reflectionViewModel = DailyVerseReflectionViewModel(verseType: .hinduVerse)
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    init(viewModel: DailyVerseViewModel, onDone: @escaping () -> Void, onChatToLearnMore: @escaping (DailyVerse) -> Void) {
        self.viewModel = viewModel
        self.onDone = onDone
        self.onChatToLearnMore = onChatToLearnMore
    }
    
    var body: some View {
        @Bindable var reflectionViewModel = reflectionViewModel

        NavigationStack {
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: DharmaTheme.Spacing.xxl) {
                        verseCardSection
                        
                        // Reflection area
                        if showReflection {
                            VStack(alignment: .leading, spacing: DharmaTheme.Spacing.sm) {
                                Text("Your Reflection")
                                    .font(DharmaTheme.Typography.uiHeadline(16))
                                    .foregroundColor(DharmaTheme.Colors.onSurface)
                                
                                TextEditor(text: $reflectionViewModel.reflectionText)
                                    .font(DharmaTheme.Typography.uiBody())
                                    .foregroundColor(DharmaTheme.Colors.onSurface)
                                    .tint(DharmaTheme.Colors.saffron)
                                    .frame(minHeight: 100)
                                    .padding(DharmaTheme.Spacing.sm)
                                    .background(DharmaTheme.Colors.surface)
                                    .cornerRadius(DharmaTheme.Radius.md)
                                    .scrollContentBackground(.hidden)

                                HStack {
                                    Text(reflectionViewModel.storageHint)
                                        .font(DharmaTheme.Typography.uiCaption(11))
                                        .foregroundColor(DharmaTheme.Colors.secondaryText)

                                    Spacer()

                                    Text("\(reflectionViewModel.characterCount) characters")
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
                        addCurrentVerseAsWidget()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "rectangle.grid.2x2")
                                .font(.system(size: 14))
                            Text("Add as Widget")
                                .font(DharmaTheme.Typography.uiCaption())
                        }
                    }
                    .buttonStyle(.ghost)
                    .disabled(viewModel.verse == nil)

                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showReflection.toggle()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil.circle")
                                .font(.system(size: 16))
                            Text(reflectionViewModel.hasReflection ? "Edit reflection" : "Reflection")
                                .font(DharmaTheme.Typography.uiCaption())
                        }
                    }
                    .buttonStyle(.ghost)
                    
                    Button {
                        guard let verse = viewModel.verse else { return }
                        onChatToLearnMore(verse)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "bubble.left.fill")
                                .font(.system(size: 14))
                            Text("Chat to learn more")
                                .font(DharmaTheme.Typography.uiCaption())
                        }
                    }
                    .buttonStyle(.ghost)
                    .disabled(viewModel.verse == nil)
                    
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
            .navigationTitle("Daily Verse")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(DailyVerseViewModel.TraditionFilter.allCases) { tradition in
                            Button {
                                Task {
                                    await selectTradition(tradition)
                                }
                            } label: {
                                if tradition == viewModel.selectedTradition {
                                    Label(tradition.title, systemImage: "checkmark")
                                } else {
                                    Text(tradition.title)
                                }
                            }
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Text(viewModel.selectedTradition.title)
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
        .task {
            await viewModel.loadVerse()
            reflectionViewModel.selectVerseType(viewModel.selectedTradition.taskType)
            showReflection = reflectionViewModel.hasReflection
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }

            Task {
                await viewModel.loadVerse()
                reloadReflection()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            Task {
                await viewModel.loadVerse(forceReload: true)
                reloadReflection()
            }
        }
        .sheet(isPresented: $showWidgetInstructions) {
            DailyVerseWidgetInstructionsView(tradition: viewModel.selectedTradition)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }

    private func selectTradition(_ tradition: DailyVerseViewModel.TraditionFilter) async {
        let wasShowingReflection = showReflection
        await viewModel.selectTradition(tradition)
        reflectionViewModel.selectVerseType(tradition.taskType)
        showReflection = wasShowingReflection || reflectionViewModel.hasReflection
    }

    @ViewBuilder
    private var verseCardSection: some View {
        if viewModel.isLoading && viewModel.verse == nil {
            VStack(spacing: DharmaTheme.Spacing.lg) {
                ProgressView()
                    .tint(DharmaTheme.Colors.saffron)

                Text("Selecting today’s verse...")
                    .font(DharmaTheme.Typography.uiBody())
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DharmaTheme.Spacing.xxxl)
            .background(DharmaTheme.Colors.surface)
            .cornerRadius(DharmaTheme.Radius.lg)
            .padding(.horizontal, DharmaTheme.Spacing.sm)
        } else if let verse = viewModel.verse {
            VStack(spacing: DharmaTheme.Spacing.md) {
                Button {
                    withAnimation(.spring(response: 0.45, dampingFraction: 0.86)) {
                        viewModel.toggleCardFace()
                    }
                } label: {
                    ZStack {
                        verseCardFace(
                            verse: verse,
                            title: "ENGLISH",
                            bodyText: verse.englishText,
                            hint: "Tap to reveal the traditional text"
                        )
                        .opacity(viewModel.isShowingTraditionalText ? 0 : 1)

                        verseCardFace(
                            verse: verse,
                            title: "TRADITIONAL",
                            bodyText: verse.displayedTraditionalText,
                            hint: verse.hasTraditionalText ? "Tap to return to the English translation" : "Traditional text unavailable for this verse"
                        )
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .opacity(viewModel.isShowingTraditionalText ? 1 : 0)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 420)
                    .rotation3DEffect(
                        .degrees(viewModel.isShowingTraditionalText ? 180 : 0),
                        axis: (x: 0, y: 1, z: 0)
                    )
                }
                .buttonStyle(.plain)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(DharmaTheme.Typography.uiCaption())
                        .foregroundColor(DharmaTheme.Colors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, DharmaTheme.Spacing.lg)
                }
            }
            .padding(.horizontal, DharmaTheme.Spacing.sm)
        } else {
            VStack(spacing: DharmaTheme.Spacing.md) {
                Text(viewModel.errorMessage ?? "No daily verse is available right now.")
                    .font(DharmaTheme.Typography.uiBody())
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
                    .multilineTextAlignment(.center)

                Button("Try Again") {
                    Task {
                        await viewModel.loadVerse(forceReload: true)
                    }
                }
                .buttonStyle(.saffron)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DharmaTheme.Spacing.xxxl)
            .padding(.horizontal, DharmaTheme.Spacing.lg)
            .background(DharmaTheme.Colors.surface)
            .cornerRadius(DharmaTheme.Radius.lg)
            .padding(.horizontal, DharmaTheme.Spacing.sm)
        }
    }

    private func reloadReflection() {
        reflectionViewModel.loadReflection()
        showReflection = showReflection || reflectionViewModel.hasReflection
    }

    private func addCurrentVerseAsWidget() {
        guard let verse = viewModel.verse else { return }

        DailyVerseStore().saveVerse(verse, for: viewModel.selectedTradition)

#if canImport(WidgetKit)
        WidgetCenter.shared.reloadTimelines(ofKind: DailyVerseWidgetConstants.kind)
#endif

        showWidgetInstructions = true
    }

    private func verseCardFace(verse: DailyVerse, title: String, bodyText: String, hint: String) -> some View {
        VStack(spacing: DharmaTheme.Spacing.lg) {
            Text(verse.traditionIcon)
                .font(.system(size: 46))
                .padding(.top, DharmaTheme.Spacing.xxl)

            VStack(spacing: DharmaTheme.Spacing.sm) {
                Text(title)
                    .font(DharmaTheme.Typography.uiLabel(13))
                    .foregroundColor(DharmaTheme.Colors.saffron)
                    .tracking(1.5)

                Text(verse.traditionLabel)
                    .font(DharmaTheme.Typography.uiCaption(12))
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
            }

            Text(bodyText)
                .font(DharmaTheme.Typography.scriptureBody(20))
                .foregroundColor(DharmaTheme.Colors.onSurface)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.horizontal, DharmaTheme.Spacing.lg)

            Spacer(minLength: DharmaTheme.Spacing.md)

            VStack(spacing: DharmaTheme.Spacing.xs) {
                Text(verse.referenceText)
                    .font(DharmaTheme.Typography.uiHeadline(15))
                    .foregroundColor(DharmaTheme.Colors.onSurface)

                Text(hint)
                    .font(DharmaTheme.Typography.uiCaption())
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
            }
            .padding(.bottom, DharmaTheme.Spacing.xxl)
        }
        .frame(maxWidth: .infinity, minHeight: 420)
        .background(DharmaTheme.Colors.surface)
        .cornerRadius(DharmaTheme.Radius.lg)
    }
}

private struct DailyVerseWidgetInstructionsView: View {
    let tradition: DailyVerseViewModel.TraditionFilter
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: DharmaTheme.Spacing.lg) {
            Capsule()
                .fill(DharmaTheme.Colors.outlineVariant)
                .frame(width: 44, height: 5)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: DharmaTheme.Spacing.sm) {
                Text("Daily verse ready for your Home Screen")
                    .font(DharmaTheme.Typography.uiTitle(24))
                    .foregroundColor(DharmaTheme.Colors.onSurface)

                Text("Your \(tradition.title.lowercased()) verse is now available to the Dharma widget.")
                    .font(DharmaTheme.Typography.uiBody())
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
            }

            VStack(alignment: .leading, spacing: DharmaTheme.Spacing.md) {
                DailyVerseWidgetStep(number: "1", text: "Touch and hold your Home Screen until the icons start to jiggle.")
                DailyVerseWidgetStep(number: "2", text: "Tap Edit or the Add button, then search for Dharma.")
                DailyVerseWidgetStep(number: "3", text: "Choose the Daily Verse widget size and tap Add Widget.")
            }

            Text("The widget refreshes automatically whenever today’s verse changes in the app.")
                .font(DharmaTheme.Typography.uiCaption())
                .foregroundColor(DharmaTheme.Colors.secondaryText)

            Button("Close") {
                dismiss()
            }
            .buttonStyle(.saffron)
            .frame(maxWidth: .infinity, alignment: .trailing)

            Spacer(minLength: 0)
        }
        .padding(DharmaTheme.Spacing.xl)
        .background(Color.white)
    }
}

private struct DailyVerseWidgetStep: View {
    let number: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: DharmaTheme.Spacing.md) {
            Text(number)
                .font(DharmaTheme.Typography.uiHeadline(14))
                .foregroundColor(.white)
                .frame(width: 28, height: 28)
                .background(DharmaTheme.Colors.saffron)
                .clipShape(Circle())

            Text(text)
                .font(DharmaTheme.Typography.uiBody())
                .foregroundColor(DharmaTheme.Colors.onSurface)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    DailyVerseDetailView(viewModel: DailyVerseViewModel(), onDone: {}, onChatToLearnMore: { _ in })
}

