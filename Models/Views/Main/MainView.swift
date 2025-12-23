import SwiftUI

struct MainView: View {

    enum Tab: Hashable {
        case home
        case add
        case history
        case categories
        case settings
    }

    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {

            HomeView()
                .tabItem {
                    Label("Accueil", systemImage: "house")
                }
                .tag(Tab.home)

            AddTicketView()
                .tabItem {
                    Label("Ajouter", systemImage: "plus.circle")
                }
                .tag(Tab.add)

            TicketHistoryView()
                .tabItem {
                    Label("Historique", systemImage: "list.bullet")
                }
                .tag(Tab.history)

            CategoryStatsView()
                .tabItem {
                    Label("Catégories", systemImage: "chart.pie")
                }
                .tag(Tab.categories)

            SettingsView()
                .tabItem {
                    Label("Paramètres", systemImage: "gearshape")
                }
                .tag(Tab.settings)
        }
        .tint(Color(Theme.primaryBlue))

        // MARK: - Navigation wiring
        .onReceive(NotificationCenter.default.publisher(for: .goToHome)) { _ in
            Haptic.light()
            selectedTab = .home
        }

        .onReceive(NotificationCenter.default.publisher(for: .goToAddTicket)) { _ in
            Haptic.light()
            selectedTab = .add
        }

        .onReceive(NotificationCenter.default.publisher(for: .goToHistory)) { _ in
            Haptic.light()
            selectedTab = .history
        }

        .onReceive(NotificationCenter.default.publisher(for: .goToHistoryToday)) { _ in
            Haptic.light()
            selectedTab = .history
        }

        .onReceive(NotificationCenter.default.publisher(for: .goToHistoryMonth)) { _ in
            Haptic.light()
            selectedTab = .history
        }
    }
}
