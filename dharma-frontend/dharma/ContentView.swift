import SwiftUI
import UIKit

struct ContentView: View {
    @State private var selectedTab: Tab = .today
    @State private var homeViewModel = HomeViewModel()
    @State private var scriptureViewModel = ScriptureViewModel()
    @State private var chatViewModel = ChatViewModel()
    @State private var learnViewModel = LearnViewModel()
    @State private var dailyVerseViewModel = DailyVerseViewModel()
    @Environment(\.scenePhase) private var scenePhase
    
    enum Tab: String {
        case chat = "Chat"
        case today = "Today"
        case scriptures = "Scriptures"
        case learn = "Learn"
        
        var icon: String {
            switch self {
            case .chat: return "bubble.left.and.bubble.right"
            case .today: return "calendar"
            case .scriptures: return "book.closed"
            case .learn: return "graduationcap"
            }
        }
    }
    
    var body: some View {
        ZStack {
            DharmaTheme.Colors.surfaceContainerLowest
                .ignoresSafeArea()

            TabView(selection: $selectedTab) {
                ChatView(viewModel: chatViewModel)
                    .tabItem {
                        Label(Tab.chat.rawValue, systemImage: Tab.chat.icon)
                    }
                    .tag(Tab.chat)
                
                HomeView(
                    viewModel: homeViewModel,
                    dailyVerseViewModel: dailyVerseViewModel,
                    openVerseExplanationChat: openVerseExplanationChat
                )
                    .tabItem {
                        Label(Tab.today.rawValue, systemImage: Tab.today.icon)
                    }
                    .tag(Tab.today)
                
                ScriptureListView(viewModel: scriptureViewModel)
                    .tabItem {
                        Label(Tab.scriptures.rawValue, systemImage: Tab.scriptures.icon)
                    }
                    .tag(Tab.scriptures)
                
                LearnView(viewModel: learnViewModel)
                    .tabItem {
                        Label(Tab.learn.rawValue, systemImage: Tab.learn.icon)
                    }
                    .tag(Tab.learn)
            }
            .background(DharmaTheme.Colors.surfaceContainerLowest)
        }
        .tint(DharmaTheme.Colors.saffron)
        .task {
            await dailyVerseViewModel.loadVerse()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }

            Task {
                await dailyVerseViewModel.loadVerse()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
            Task {
                await dailyVerseViewModel.loadVerse(forceReload: true)
            }
        }
    }

    private func openVerseExplanationChat(for verse: DailyVerse) {
        chatViewModel.sendPrefilledMessage(
            verse.explanationPrompt,
            resetConversation: true
        )
        selectedTab = .chat
    }
}

#Preview {
    ContentView()
}
