import SwiftUI
import UIKit

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    @Bindable var dailyVerseViewModel: DailyVerseViewModel
    let openVerseExplanationChat: (DailyVerse) -> Void
    @Environment(AuthViewModel.self) private var authViewModel
    @Environment(\.scenePhase) private var scenePhase
    @State private var showingVerseDetail = false
    @State private var showingMeditation = false
    @State private var showingMantra = false
    @State private var showingJournal = false
    @State private var showingSettings = false
    @State private var showingSacredDates = false
    @State private var showingWidgetInstructions = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DharmaTheme.Spacing.xl) {
                // Header
                headerSection
                
                // Week Calendar Strip
                WeekCalendarView(dates: viewModel.weekDates)
                
                // Progress Bar
                progressSection
                
                // Daily Task Grid
                taskGrid

                // Widget prompt
                widgetPromptRow
            }
            .padding(.horizontal, DharmaTheme.Spacing.lg)
            .padding(.bottom, DharmaTheme.Spacing.xxxl)
        }
        .background(Color.white)
        .sheet(isPresented: $showingVerseDetail) {
            DailyVerseDetailView(
                viewModel: dailyVerseViewModel,
                onDone: {
                    markTaskDone(.dailyVerse)
                    showingVerseDetail = false
                },
                onChatToLearnMore: { verse in
                    showingVerseDetail = false
                    openVerseExplanationChat(verse)
                }
            )
        }
        .fullScreenCover(isPresented: $showingMeditation) {
            MeditationView(onDone: {
                markTaskDone(.meditation)
                showingMeditation = false
            })
        }
        .sheet(isPresented: $showingMantra) {
            MantraView(onDone: {
                markTaskDone(.mantra)
                showingMantra = false
            })
        }
        .sheet(isPresented: $showingJournal) {
            GratitudeJournalView(onDone: {
                markTaskDone(.gratitude)
                showingJournal = false
            })
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .presentationDetents([.height(430)])
                .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showingSacredDates) {
            SacredObservanceCalendarView(
                observances: viewModel.upcomingSacredDates,
                isLoading: viewModel.isLoadingSacredDates,
                errorMessage: viewModel.sacredDatesErrorMessage,
                onDone: {
                markTaskDone(.sacredDates)
                showingSacredDates = false
                }
            )
        }
        .sheet(isPresented: $showingWidgetInstructions) {
            HomeWidgetInstructionsView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .task {
            await viewModel.refreshForCurrentContext()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }

            Task {
                await viewModel.refreshForCurrentContext()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            Task {
                await viewModel.refreshForCurrentContext()
            }
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        HStack {
            // App Logo (tappable for settings)
            Button {
                showingSettings = true
            } label: {
                ZStack {
                    Circle()
                        .stroke(DharmaTheme.Colors.saffron.opacity(0.3), lineWidth: 2)
                        .frame(width: 48, height: 48)
                    Text(authViewModel.avatarInitial)
                        .font(DharmaTheme.Typography.scriptureHeadline(22))
                        .foregroundColor(DharmaTheme.Colors.saffron)
                }
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Dharma's Journey")
                    .font(DharmaTheme.Typography.uiTitle(20))
                    .foregroundColor(DharmaTheme.Colors.onSurface)
                Text("Your Daily Path")
                    .font(DharmaTheme.Typography.uiCaption())
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
            }
            
            Spacer()
            
            // Streak counter
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 4) {
                    Text("🔥")
                        .font(.system(size: 18))
                    Text("\(viewModel.streakCount)")
                        .font(DharmaTheme.Typography.uiHeadline(16))
                        .foregroundColor(DharmaTheme.Colors.onSurface)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(DharmaTheme.Colors.cardHindu)
                .cornerRadius(DharmaTheme.Radius.md)
            }
        }
        .padding(.top, DharmaTheme.Spacing.sm)
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: DharmaTheme.Spacing.sm) {
            HStack {
                Text("Your Path Today")
                    .font(DharmaTheme.Typography.uiTitle(20))
                    .foregroundColor(DharmaTheme.Colors.onSurface)
                Spacer()
                Text(viewModel.progressText)
                    .font(DharmaTheme.Typography.uiHeadline(16))
                    .foregroundColor(DharmaTheme.Colors.onSurface)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(DharmaTheme.Colors.surfaceContainerLow)
                        .frame(height: 10)
                    
                    RoundedRectangle(cornerRadius: 6)
                        .fill(DharmaTheme.Colors.saffron)
                        .frame(width: geometry.size.width * viewModel.progressPercentage, height: 10)
                        .animation(.easeInOut(duration: 0.5), value: viewModel.progressPercentage)
                }
            }
            .frame(height: 10)
        }
    }
    
    // MARK: - Task List
    private var taskGrid: some View {
        VStack(spacing: DharmaTheme.Spacing.md) {
            ForEach(viewModel.tasks) { task in
                DailyTaskRow(task: task) {
                    handleTaskTap(task)
                }
            }
        }
    }

    // MARK: - Widget Prompt
    private var widgetPromptRow: some View {
        Button {
            showingWidgetInstructions = true
        } label: {
            HStack(spacing: DharmaTheme.Spacing.sm) {
                Image(systemName: "arrow.up.doc")
                    .font(.system(size: 16))
                    .foregroundColor(DharmaTheme.Colors.saffron)

                Text("Adding Daily Verses to the Home Screen?")
                    .font(DharmaTheme.Typography.uiCaption())
                    .foregroundColor(DharmaTheme.Colors.onSurface)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, DharmaTheme.Spacing.sm)
            .padding(.horizontal, DharmaTheme.Spacing.md)
            .background(DharmaTheme.Colors.surface)
            .cornerRadius(DharmaTheme.Radius.md)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions
    private func handleTaskTap(_ task: DailyTask) {
        switch task.taskType {
        case .dailyVerse:
            showingVerseDetail = true
        case .hinduVerse, .buddhistVerse:
            showingVerseDetail = true
        case .meditation:
            showingMeditation = true
        case .mantra:
            showingMantra = true
        case .journal, .gratitude:
            showingJournal = true
        case .sacredDates:
            showingSacredDates = true
        }
    }
    
    private func markTaskDone(_ type: DailyTask.TaskType) {
        if let task = viewModel.tasks.first(where: { $0.taskType == type }) {
            viewModel.markTaskCompleted(task)
        }
    }
}

private struct HomeWidgetInstructionsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: DharmaTheme.Spacing.lg) {
            Capsule()
                .fill(DharmaTheme.Colors.outlineVariant)
                .frame(width: 44, height: 5)
                .frame(maxWidth: .infinity)

            VStack(alignment: .leading, spacing: DharmaTheme.Spacing.sm) {
                Text("Add Daily Verses to your Home Screen")
                    .font(DharmaTheme.Typography.uiTitle(24))
                    .foregroundColor(DharmaTheme.Colors.onSurface)

                Text("See today's verse at a glance with the Dharma widget.")
                    .font(DharmaTheme.Typography.uiBody())
                    .foregroundColor(DharmaTheme.Colors.secondaryText)
            }

            VStack(alignment: .leading, spacing: DharmaTheme.Spacing.md) {
                WidgetStep(number: "1", text: "Touch and hold your Home Screen until the icons start to jiggle.")
                WidgetStep(number: "2", text: "Tap Edit or the Add button, then search for Dharma.")
                WidgetStep(number: "3", text: "Choose the Daily Verse widget and tap Add Widget.")
                WidgetStep(number: "4", text: "Touch and hold the widget, choose Edit Widget, then select Hindu or Buddhist.")
            }

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

private struct WidgetStep: View {
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
    let authViewModel = AuthViewModel()
    authViewModel.currentUserEmail = "seeker@dharma.app"

    return HomeView(viewModel: HomeViewModel(), dailyVerseViewModel: DailyVerseViewModel(), openVerseExplanationChat: { _ in })
        .environment(authViewModel)
}
