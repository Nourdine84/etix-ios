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
            
            CategoryView()
                .tabItem {
                    Label("Catégories", systemImage: "chart.pie.fill")
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
