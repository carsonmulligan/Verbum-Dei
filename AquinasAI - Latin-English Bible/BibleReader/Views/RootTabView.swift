import SwiftUI

/// Root of the redesigned app: a three-tab shell (Today / Bible / Prayers).
/// Owns the shared app state and injects it into every tab so playback and
/// data stay in sync across them. The Bible tab is the original home, unchanged.
struct RootTabView: View {
    @StateObject private var viewModel = BibleViewModel()
    @StateObject private var bookmarkStore = BookmarkStore()
    @StateObject private var prayerStore = PrayerStore()
    @StateObject private var audioManager = AudioManager()
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("rootSelectedTab") private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView(selectedTab: $selectedTab)
                .tabItem { Label("Today", systemImage: "sun.max") }
                .tag(0)

            ContentView()
                .tabItem { Label("Bible", systemImage: "book.closed") }
                .tag(1)

            PrayersView(showsDoneButton: false)
                .tabItem { Label("Prayers", systemImage: "hands.sparkles") }
                .tag(2)
        }
        .tint(.deepPurple)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .environmentObject(viewModel)
        .environmentObject(bookmarkStore)
        .environmentObject(prayerStore)
        .environmentObject(audioManager)
    }
}

#Preview {
    RootTabView()
}
