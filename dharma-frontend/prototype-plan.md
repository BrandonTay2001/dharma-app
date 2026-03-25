# Dharma App SwiftUI Frontend

Build the complete SwiftUI frontend for a spirituality app focused on Buddhism/Hinduism. The existing Xcode project at `/Users/brandon/Coding/dharma-app/dharma` has boilerplate files; we will add all views, models, and theme files.

## Proposed Changes

All new files are created under `/Users/brandon/Coding/dharma-app/dharma/dharma/`.

---

### Theme & Design System

#### [NEW] [Theme.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/Theme.swift)
Centralized design tokens: Saffron (`#FF7722`) accent, surface colors, text colors, font helpers for Noto Serif (scripture) and system sans-serif (UI).

---

### Data Models

#### [NEW] [Models/Scripture.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/Models/Scripture.swift)
`Scripture`, `Chapter`, `Verse` structs with sample data for Bhagavad Gita Ch.2 and Dhammapada Ch.1.

#### [NEW] [Models/ChatMessage.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/Models/ChatMessage.swift)
`ChatMessage` model (id, text, isUser, timestamp).

#### [NEW] [Models/DailyTask.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/Models/DailyTask.swift)
`DailyTask` model (id, title, duration, isCompleted, icon, color) and sample data for all 6 daily tasks.

#### [NEW] [Models/MeditationStep.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/Models/MeditationStep.swift)
`MeditationStep` model for guided meditation phases (inhale/hold/exhale prompts).

---

### ViewModels

#### [NEW] [ViewModels/HomeViewModel.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/ViewModels/HomeViewModel.swift)
Manages daily tasks list, streak count, progress calculation, and task completion toggling.

#### [NEW] [ViewModels/ScriptureViewModel.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/ViewModels/ScriptureViewModel.swift)
Manages scripture list, selected scripture/chapter, and chapter navigation.

#### [NEW] [ViewModels/ChatViewModel.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/ViewModels/ChatViewModel.swift)
Manages message list, daily message limit (5/day hardcoded), and message sending with mock AI responses.

#### [NEW] [ViewModels/MeditationViewModel.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/ViewModels/MeditationViewModel.swift)
Manages meditation timer, breathing phases, and session progress.

---

### Views — Tab Navigation

#### [MODIFY] [ContentView.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/ContentView.swift)
Replace boilerplate with a `TabView` containing 4 tabs: Chat, Today (Home), Scriptures, Learn. Uses saffron accent for active tab. Instantiates shared ViewModels.

---

### Views — Home / Dashboard

#### [NEW] [Views/Home/HomeView.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/Views/Home/HomeView.swift)
Dashboard with header (app logo, streak counter), week calendar strip, progress bar ("Your Path Today"), and 2-column grid of daily task cards.

#### [NEW] [Views/Home/WeekCalendarView.swift](file:///Users/Coding/dharma-app/dharma/dharma/Views/Home/WeekCalendarView.swift)
Horizontal strip showing M-S day labels + date numbers with saffron ring on today.

#### [NEW] [Views/Home/DailyTaskCard.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/Views/Home/DailyTaskCard.swift)
Individual task card with icon, title, duration, and DONE button. Matches design grid cards.

---

### Views — Daily Verse Detail

#### [NEW] [Views/DailyVerse/DailyVerseDetailView.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/Views/DailyVerse/DailyVerseDetailView.swift)
Full-screen verse display with lotus icon, "VERSE OF THE DAY" label, centered serif text, progress bar, and bottom action buttons (Reflection, Chat to learn more, Done).

---

### Views — Scripture Reading

#### [NEW] [Views/Scripture/ScriptureListView.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/Views/Scripture/ScriptureListView.swift)
List of available scriptures (Bhagavad Gita, Dhammapada) with chapter counts.

#### [NEW] [Views/Scripture/ScriptureReaderView.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/Views/Scripture/ScriptureReaderView.swift)
Reading view with chapter dropdown, saffron verse numbers, serif body text, and bottom persistent audio/settings bar.

---

### Views — Spiritual Chat

#### [NEW] [Views/Chat/ChatView.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/Views/Chat/ChatView.swift)
Chat interface with "Spiritual Guidance" header, daily limit indicator (X/5), message bubbles (saffron for AI, grey for user), and input bar with send button.

#### [NEW] [Views/Chat/ChatBubbleView.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/Views/Chat/ChatBubbleView.swift)
Individual chat bubble component with appropriate styling per sender.

---

### Views — Meditation

#### [NEW] [Views/Meditation/MeditationView.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/Views/Meditation/MeditationView.swift)
Minimalist meditation screen with breathing prompt text, pulsing lotus animation, step progress dots, timer, and Done button.

---

### Views — Mantra

#### [NEW] [Views/Mantra/MantraView.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/Views/Mantra/MantraView.swift)
Daily mantra display with Om symbol, Sanskrit text with translation, and bead counter for repetitions.

---

### Views — Gratitude Journal

#### [NEW] [Views/Journal/GratitudeJournalView.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/Views/Journal/GratitudeJournalView.swift)
Simple journaling interface with text editor, date header, and save/done button.

---

### Views — Learn Tab

#### [NEW] [Views/Learn/LearnView.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/Views/Learn/LearnView.swift)
Placeholder screen with curated topic cards (Karma, Dharma, Four Noble Truths, etc.) for future content.

---

### App Entry Point

#### [MODIFY] [dharmaApp.swift](file:///Users/brandon/Coding/dharma-app/dharma/dharma/dharmaApp.swift)
No changes needed — already loads `ContentView`.

---

## Verification Plan

### Automated Tests
SwiftUI previews are embedded in each view file via `#Preview`. No unit test targets exist in this project currently.

### Manual Verification
1. Open `/Users/brandon/Coding/dharma-app/dharma/dharma.xcodeproj` in Xcode
2. Build the project (⌘B) — should compile with zero errors
3. Run in iOS Simulator (⌘R) and verify:
   - Tab navigation works across all 4 tabs
   - Home dashboard shows week strip, progress bar, and task grid
   - Tapping a daily verse card navigates to verse detail
   - Scripture tab lists Gita & Dhammapada, tapping navigates to reader
   - Chat tab shows message limit and can send/receive mock messages
   - Meditation view shows breathing animation and timer
4. Compare each screen against the design screenshots in `project-guidelines/designs/`
