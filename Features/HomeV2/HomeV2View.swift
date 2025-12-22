import SwiftUI

struct HomeV2View: View {

    @StateObject private var viewModel = HomeV2ViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                header

                HomeKPIView(
                    total: viewModel.totalAmount,
                    count: viewModel.ticketsCount,
                    month: viewModel.monthAmount
                )

                HomeQuickActionsView()
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Accueil")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Bonjour 👋")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Voici un aperçu de tes dépenses")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    NavigationStack {
        HomeV2View()
    }
}
