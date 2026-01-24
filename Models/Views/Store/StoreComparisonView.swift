import SwiftUI
import CoreData

struct StoreComparisonView: View {

    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = StoreComparisonViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                if vm.stores.isEmpty {
                    emptyState
                } else {

                    // 🏆 TOP 3
                    VStack(spacing: 12) {
                        ForEach(vm.stores.prefix(3).indices, id: \.self) { index in
                            topRow(store: vm.stores[index], rank: index + 1)
                        }
                    }
                    .padding(.horizontal)

                    Divider().padding(.vertical)

                    // 📋 LISTE COMPLÈTE
                    VStack(spacing: 12) {
                        ForEach(vm.stores) { store in
                            NavigationLink {
                                StoreDetailView(storeName: store.storeName)
                            } label: {
                                storeRow(store)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Comparaison")
        .onAppear {
            vm.load(context: context)
        }
    }

    // MARK: - Top Row
    private func topRow(store: StoreTotal, rank: Int) -> some View {
        HStack {
            Text(rank == 1 ? "🥇" : rank == 2 ? "🥈" : "🥉")
                .font(.largeTitle)

            VStack(alignment: .leading, spacing: 4) {
                Text(store.storeName)
                    .font(.headline)

                Text("Panier moyen : \(String(format: "%.2f €", store.total / Double(max(store.ticketCount, 1))))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(String(format: "%.2f €", store.total))
                .fontWeight(.bold)
                .foregroundColor(Color(Theme.primaryBlue))
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }

    // MARK: - Row
    private func storeRow(_ store: StoreTotal) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(store.storeName)
                    .font(.headline)

                Text("\(store.ticketCount) ticket(s)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(String(format: "%.2f €", store.total))
                    .fontWeight(.semibold)

                Text("Moy. \(String(format: "%.2f €", store.total / Double(max(store.ticketCount, 1))))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    // MARK: - Empty
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.system(size: 40))
                .foregroundColor(.gray)

            Text("Aucune donnée")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
