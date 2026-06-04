import SwiftUI

struct MainView: View {

    @State private var selectedTab: Int = 0

    var body: some View {

        TabView(selection: $selectedTab) {

            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Accueil")
                }
                .tag(0)

            AddTicketView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Ajouter")
                }
                .tag(1)

            TicketHistoryView()
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Historique")
                }
                .tag(2)

            CategoryView()
                .tabItem {
                    Label("Catégories", systemImage: "chart.pie.fill")
                }
                .tag(3)

            StoreListView(categoryName: nil)
                .tabItem {
                    Label("Magasins", systemImage: "building.2")
                }
                .tag(4)

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Réglages")
                }
                .tag(5)
        }
        .tint(Theme.primaryBlue)
        .tabViewStyle(.automatic)
        .animation(.easeInOut(duration: 0.28), value: selectedTab)
        .onChange(of: selectedTab) { _ in
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.prepare()
            generator.impactOccurred()
        }
        .environment(\.selectedTabBinding, $selectedTab)
    }
}
