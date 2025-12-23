import SwiftUI

struct MainView: View {

    enum Tab: Hashable {
        case home
        case add
        case history
        case categories   // 👈 AJOUT
        case settings
    }

    @State private var selected: Tab = .home

    var body: some View {
        TabView(selection: $selected) {

            // MARK: - Accueil
            HomeView()
                .tabItem {
                    Label("Accueil", systemImage: "house")
                }
                .tag(Tab.home)

            // MARK: - Ajouter
            AddTicketView()
                .tabItem {
                    Label("Ajouter", systemImage: "plus.circle")
                }
                .tag(Tab.add)

            // MARK: - Historique
            TicketHistoryView()
                .tabItem {
                    Label("Historique", systemImage: "list.bullet")
                }
                .tag(Tab.history)

            // MARK: - Catégories (V2)
            CategoryStatsView()
                .tabItem {
                    Label("Catégories", systemImage: "chart.pie.fill")
                }
                .tag(Tab.categories)

            // MARK: - Paramètres
            SettingsView()
                .tabItem {
                    Label("Paramètres", systemImage: "gearshape")
                }
                .tag(Tab.settings)
        }
        .tint(Color(Theme.primaryBlue))
        .onChange(of: selected) {
            Haptic.light()
        }
    }
}
