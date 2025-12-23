import SwiftUI

enum MainTab {
    case home, add, history, categories, settings
}

struct MainView: View {

    @State private var selectedTab: MainTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {

            HomeView()
                .tabItem {
                    Label("Accueil", systemImage: "house")
                }
                .tag(MainTab.home)

            AddTicketView()
                .tabItem {
                    Label("Ajouter", systemImage: "plus.circle")
                }
                .tag(MainTab.add)

            TicketHistoryView()
                .tabItem {
                    Label("Historique", systemImage: "list.bullet")
                }
                .tag(MainTab.history)

            CategoryView()
                .tabItem {
                    Label("Catégories", systemImage: "chart.pie")
                }
                .tag(MainTab.categories)

            SettingsView()
                .tabItem {
                    Label("Réglages", systemImage: "gear")
                }
                .tag(MainTab.settings)
        }
        // 🔁 RETOUR HOME APRÈS AJOUT
        .onReceive(NotificationCenter.default.publisher(for: .ticketAdded)) { _ in
            selectedTab = .home
        }
    }
}
