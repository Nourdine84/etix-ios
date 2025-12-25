import SwiftUI

struct HomeV2View: View {

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {

                    // 🔵 Header
                    headerSection

                    // ⚡ Actions rapides
                    HomeQuickActionsView()

                    // 🧱 Placeholder sections (à venir)
                    placeholderCard(title: "Derniers tickets")
                    placeholderCard(title: "Statistiques du mois")

                }
                .padding()
            }
            .navigationTitle("Accueil")
        }
    }
}

// MARK: - Sections
private extension HomeV2View {

    var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text("Bienvenue 👋")
                .font(.title2.bold())

            Text("Voici un aperçu de ton activité")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    func placeholderCard(title: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(title)
                .font(.headline)

            Text("Contenu à venir")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }
}

// MARK: - Preview
#Preview {
    HomeV2View()
}
