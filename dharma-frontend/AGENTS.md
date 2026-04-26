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
│   ├── SacredObservance.swift     # Sacred observance model + 7-day planner for lunar/weekday rituals
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
    ├── Observance/
    │   └── SacredObservanceView.swift  # 7-day sacred observance list + observance detail flow
    ├── Paywall/
    │   └── SubscriptionRequiredView.swift  # Shown when subscription lapses; resubscribe, restore, sign out
    └── Settings/
        └── SettingsView.swift          # Bottom sheet: Help & Support, Log Out

dharma-widget-extension/
├── DailyVerseWidget.swift          # Widget timeline/provider/view for the Daily Verse widget
├── dharma_widget_extension.swift   # Widget bundle entry point
├── Info.plist                      # Widget extension metadata and bundle versioning
└── dharma-widget-extension.entitlements # App Group entitlement for shared widget data
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
- `HomeViewModel.upcomingSacredDates` uses `SacredObservancePlanner.nextSevenDays()` to surface Hindu/Buddhist observances in the home flow
- Day changes are handled via `significantTimeChangeNotification` and `scenePhase` observers
- Sacred observances are currently frontend-generated in `SacredObservance.swift`, combining lunar-phase checks with weekday-based ritual suggestions
- Daily Verse widget data is shared through the App Group `group.xyz.618263.dharma`; app-side widget support lives in `dharma/Shared/DailyVerseWidgetSupport.swift`
- Widget refreshes should go through `WidgetCenter` after writing shared data so the Home Screen widget updates immediately

## Widget Notes

- The project includes a WidgetKit extension target named `dharma-widget-extension` for the Daily Verse widget
- The widget extension bundle identifier must stay prefixed by the parent app bundle identifier: `xyz.618263.dharma.dharma-widget-extension`
- The widget Info.plist must include standard extension metadata, including `CFBundleIdentifier`, `CFBundleExecutable`, `CFBundleName`, `CFBundlePackageType`, `CFBundleShortVersionString`, and `CFBundleVersion`; missing version fields cause simulator install failures with `Invalid placeholder attributes`
- Both the app target and the widget target must include the App Group entitlement `group.xyz.618263.dharma`
- The main `dharma` scheme should build the widget target as well, otherwise the app can run without producing an embedded `.appex`
- In the Xcode project, the `Embed App Extensions` copy phase must not be deployment-only; if `runOnlyForDeploymentPostprocessing = 1`, the widget will build separately but not be embedded into the app bundle for simulator runs
- If the widget does not appear in the widget gallery, first verify the installed app bundle contains `PlugIns/dharma-widget-extension.appex`

## Building

Open `dharma.xcodeproj` in Xcode, select an iOS Simulator, and run (⌘R).

- For widget changes, run the main `dharma` scheme and confirm the app installs with the embedded widget extension before debugging widget gallery visibility
- If installation fails with app extension placeholder errors, inspect the widget target's Info.plist version and bundle identifier fields first

## Paywall

- Refer to `paywall.md` for the current Superwall integration, placement names, onboarding gating flow, and auth unlock behavior

## Onboarding

- Refer to `onboarding.md` for the onboarding flow, screen copy, personalization questions, loading-screen requirements, and premium value-proposition context

## Importing

If external dependencies are required like Supabase, please ensure that the necessary import statement is present in the files!
