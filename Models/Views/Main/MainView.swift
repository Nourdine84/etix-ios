import SwiftUI

struct MainView: View {

    @State private var selectedTab: Int = 0

    var body: some View {

        TabView(selection: $selectedTab) {

            // 🏠 Accueil
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Accueil")
                }
                .tag(0)

            // ➕ Ajouter
            AddTicketView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Ajouter")
                }
                .tag(1)

            // 📜 Historique
            TicketHistoryView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Historique")
                }
                .tag(2)

            // 🧩 Catégories
            CategoryView()
                .tabItem {
                    Label("Catégories", systemImage: "chart.pie.fill")
                }
                .tag(3)

            // 🏬 Magasins
            StoreListView(categoryName: nil)
                .tabItem {
                    Label("Magasins", systemImage: "building.2")
                }
                .tag(4)

            // ⚙️ Paramètres
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Réglages")
                }
                .tag(5)
        }
        .tint(Theme.primaryBlue)
        .animation(.easeInOut(duration: 0.25), value: selectedTab)
        .onChange(of: selectedTab) { _ in
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        }
    }
}
