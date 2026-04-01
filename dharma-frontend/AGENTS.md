# Dharma iOS Frontend

SwiftUI app targeting iOS. Xcode project: `dharma.xcodeproj`.

## Architecture

```
dharma/
├── Theme.swift                    # Design tokens (colors, typography, spacing, button styles)
├── ContentView.swift              # Root TabView (Chat, Today, Scriptures, Learn)
├── Models/
│   ├── Scripture.swift            # Scripture, Chapter, Verse + sample data (Gita, Dhammapada)
│   ├── ChatMessage.swift          # Chat message model
│   ├── DailyTask.swift            # Daily task model + sample tasks
│   └── MeditationStep.swift       # Meditation breathing phases
├── ViewModels/
│   ├── HomeViewModel.swift        # Daily tasks, streak, progress, week calendar, daily completions
│   ├── ScriptureViewModel.swift   # Scripture/chapter selection & navigation
│   ├── ChatViewModel.swift        # Message list, 5/day limit, mock AI responses
│   └── MeditationViewModel.swift  # Timer, breathing phases, session state
└── Views/
    ├── Home/
    │   ├── HomeView.swift         # Dashboard: header, week strip, progress, task grid
    │   ├── WeekCalendarView.swift # M–S day strip; saffron stroke on today, filled saffron on completed days
    │   ├── DailyTaskCard.swift    # Grid card variant (active)
    │   └── DailyTaskRow.swift     # Horizontal row variant (unused, kept for reference)
    ├── DailyVerse/
    │   └── DailyVerseDetailView.swift  # Full verse display with reflection & actions
    ├── Scripture/
    │   ├── ScriptureListView.swift     # Scripture list (Gita, Dhammapada)
    │   └── ScriptureReaderView.swift   # Chapter reader with audio bar
    ├── Chat/
    │   ├── ChatView.swift              # Chat interface with limit indicator
    │   └── ChatBubbleView.swift        # Message bubble component
    ├── Meditation/
    │   └── MeditationView.swift        # Guided breathing with pulsing animation
    ├── Mantra/
    │   └── MantraView.swift            # Sanskrit mantra with bead counter
    ├── Journal/
    │   └── GratitudeJournalView.swift  # Gratitude writing with prompt chips
    ├── Learn/
    │   └── LearnView.swift             # Topic cards grid (placeholder content)
    └── Settings/
        └── SettingsView.swift          # Bottom sheet: Help & Support, Log Out
```

## Design Conventions

- **Colors:** Use `DharmaTheme.Colors.*` — never hardcode hex values
- **Typography:** Use `DharmaTheme.Typography.*` — serif for scripture, sans for UI
- **Spacing:** Use `DharmaTheme.Spacing.*` tokens
- **Buttons:** `.saffron` style for primary CTAs, `.ghost` style for secondary
- **No borders:** Use background color shifts and spacing for separation (see DESIGN.md)
- **Saffron (#FF7722):** Reserved for active states, CTAs, and verse highlights only

## Key Patterns

- ViewModels use `@Observable` (Swift Observation framework)
- Views bind via `@Bindable var viewModel`
- Navigation: `TabView` at root, `.sheet` / `.fullScreenCover` for detail screens
- Chat has a hardcoded daily limit of 5 messages (prototype)
- Scripture data is hardcoded in `Scripture.swift` — backend integration later
- User streaks are stored in the `user_streaks` Supabase table with `current_streak`, `longest_streak`, and `last_active_date`
- `UserStreakService.completeDay` updates streaks when a full day of tasks is completed, preserving same-day idempotency and consecutive-day logic
- Daily task completion dates are tracked in the `daily_completions` Supabase table (upserted when all tasks are done)
- `HomeViewModel` fetches the last 7 days of completions to highlight completed days in `WeekCalendarView`
- `HomeViewModel.refreshForCurrentContext()` reloads both streak count and recent completion dates from Supabase
- Day changes are handled via `significantTimeChangeNotification` and `scenePhase` observers

## Building

Open `dharma.xcodeproj` in Xcode, select an iOS Simulator, and run (⌘R).

## Paywall

- Refer to `paywall.md` for the current Superwall integration, placement names, onboarding gating flow, and auth unlock behavior

## Importing

If external dependencies are required like Supabase, please ensure that the necessary import statement is present in the files!
