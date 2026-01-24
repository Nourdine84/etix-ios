import SwiftUI

struct MainView: View {

    var body: some View {
        TabView {

            // 🏠 Accueil / KPI
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Accueil")
                }

            // ➕ Ajouter un ticket
            AddTicketView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Ajouter")
                }

            // 📜 Historique
            TicketHistoryView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Historique")
                }

            // 🧩 Catégories
            CategoryView()
                .tabItem {
                    Label("Catégories", systemImage: "chart.pie.fill")
                }

            // 🏬 Magasins
            StoreListView(categoryName: nil)
                .tabItem {
                    Label("Magasins", systemImage: "building.2")
                }

            // ⚙️ Paramètres
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Réglages")
                }
        }
    }
}
