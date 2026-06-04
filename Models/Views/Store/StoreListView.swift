import SwiftUI
import CoreData

struct StoreListView: View {

    let categoryName: String?

    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = StoreListViewModel()

    var body: some View {
        NavigationStack {
            ZStack {

                DesignSystem.pageBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {

                        header

                        if vm.stores.isEmpty {
                            emptyState
                        } else {
                            LazyVStack(spacing: 20) {
                                ForEach(vm.stores) { store in
                                    NavigationLink {
                                        StoreDetailView(
                                            storeName: store.storeName ?? "Inconnu"
                                        )
                                    } label: {
                                        storeCard(store)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.horizontalPadding)
                    .padding(.vertical, 30)
                }
            }
            .navigationTitle("Magasins")
            .navigationBarTitleDisplayMode(.large)
            .onAppear {
                vm.load(
                    categoryName: categoryName ?? "",
                    context: context
                )
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text("Total magasins")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("\(vm.stores.count)")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Theme.primaryBlue)
        }
        .premiumCard()
    }

    // MARK: - Store Card

    private func storeCard(_ store: StoreTotal) -> some View {

        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text(store.storeName ?? "Inconnu")
                    .font(.headline)

                Spacer()

                Text(String(format: "%.2f €", store.total))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.primaryBlue)
            }

            Text("\(store.ticketCount) ticket(s)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .premiumCard()
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 18) {
            Image(systemName: "building.2")
                .font(.system(size: 44))
                .foregroundColor(.gray)

            Text("Aucun magasin disponible")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 80)
    }
}
