import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .today
    @State private var homeViewModel = HomeViewModel()
    @State private var scriptureViewModel = ScriptureViewModel()
    @State private var chatViewModel = ChatViewModel()
    
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
        TabView(selection: $selectedTab) {
            ChatView(viewModel: chatViewModel)
                .tabItem {
                    Label(Tab.chat.rawValue, systemImage: Tab.chat.icon)
                }
                .tag(Tab.chat)
            
            HomeView(viewModel: homeViewModel)
                .tabItem {
                    Label(Tab.today.rawValue, systemImage: Tab.today.icon)
                }
                .tag(Tab.today)
            
            ScriptureListView(viewModel: scriptureViewModel)
                .tabItem {
                    Label(Tab.scriptures.rawValue, systemImage: Tab.scriptures.icon)
                }
                .tag(Tab.scriptures)
            
            LearnView()
                .tabItem {
                    Label(Tab.learn.rawValue, systemImage: Tab.learn.icon)
                }
                .tag(Tab.learn)
        }
        .tint(DharmaTheme.Colors.saffron)
    }
}

#Preview {
    ContentView()
}
