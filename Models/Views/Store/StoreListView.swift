import SwiftUI
import CoreData

struct StoreListView: View {

    let categoryName: String?

    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = StoreListViewModel()

    var body: some View {
        NavigationStack {
            ZStack {

                DesignSystem.premiumBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignSystem.verticalSpacing) {

                        header

                        if vm.stores.isEmpty {
                            emptyState
                        } else {
                            LazyVStack(spacing: DesignSystem.innerSpacing) {
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
                            .padding(.horizontal, DesignSystem.horizontalPadding)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Magasins")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            .onAppear {
                vm.load(
                    categoryName: categoryName ?? "",
                    context: context
                )
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Total magasins")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("\(vm.stores.count)")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Theme.primaryBlue)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumCard()
        .padding(.horizontal, DesignSystem.horizontalPadding)
    }

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

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "building.2")
                .font(.system(size: 42))
                .foregroundColor(.gray)

            Text("Aucun magasin disponible")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}
