import SwiftUI
import CoreData

struct StoreListView: View {

    // MARK: - Input
    let categoryName: String?

    // MARK: - CoreData
    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = StoreListViewModel()

    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                if vm.stores.isEmpty {
                    emptyState
                } else {
                    ForEach(vm.stores) { store in
                        NavigationLink {
                            StoreDetailView(
                                storeName: store.storeName ?? "Inconnu"
                            )
                        } label: {
                            storeRow(store)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Magasins")
            .toolbar {

                // 📊 Comparaison magasins
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        StoreComparisonView()
                    } label: {
                        Image(systemName: "chart.bar.fill")
                    }
                }
            }
            .onAppear {
                vm.load(
                    categoryName: categoryName ?? "",
                    context: context
                )
            }
        }
    }

    // MARK: - Row
    private func storeRow(_ store: StoreTotal) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(store.storeName ?? "Inconnu")
                    .font(.headline)

                Text("\(store.ticketCount) ticket(s)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(String(format: "%.2f €", store.total))
                .fontWeight(.semibold)
                .foregroundColor(Color(Theme.primaryBlue))
        }
        .padding(.vertical, 6)
    }

    // MARK: - Empty
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "building.2")
                .font(.system(size: 40))
                .foregroundColor(.gray)

            Text("Aucun magasin")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
