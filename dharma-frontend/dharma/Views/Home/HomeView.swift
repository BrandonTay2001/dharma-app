import SwiftUI

struct HomeView: View {
    @Bindable var viewModel: HomeViewModel
    @State private var showingVerseDetail = false
    @State private var showingMeditation = false
    @State private var showingMantra = false
    @State private var showingJournal = false
    @State private var showingSettings = false
    @State private var selectedVerseType: DailyTask.TaskType?
    
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
            }
            .padding(.horizontal, DharmaTheme.Spacing.lg)
            .padding(.bottom, DharmaTheme.Spacing.xxxl)
        }
        .background(Color.white)
        .sheet(isPresented: $showingVerseDetail) {
            DailyVerseDetailView(
                verseType: selectedVerseType ?? .hinduVerse,
                onDone: {
                    if let type = selectedVerseType {
                        markTaskDone(type)
                    }
                    showingVerseDetail = false
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
                .presentationDetents([.height(350)])
                .presentationDragIndicator(.visible)
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
                    Text("D")
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
    
    // MARK: - Actions
    private func handleTaskTap(_ task: DailyTask) {
        switch task.taskType {
        case .hinduVerse, .buddhistVerse:
            selectedVerseType = task.taskType
            showingVerseDetail = true
        case .meditation:
            showingMeditation = true
        case .mantra:
            showingMantra = true
        case .journal, .gratitude:
            showingJournal = true
        }
    }
    
    private func markTaskDone(_ type: DailyTask.TaskType) {
        if let task = viewModel.tasks.first(where: { $0.taskType == type }) {
            viewModel.markTaskCompleted(task)
        }
    }
}

#Preview {
    HomeView(viewModel: HomeViewModel())
}
