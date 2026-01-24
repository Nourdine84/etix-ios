import SwiftUI
import CoreData

struct StoreComparisonView: View {

    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = StoreComparisonViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    if vm.stores.isEmpty {
                        emptyState
                    } else {
                        StoreComparisonBarChartView(
                            stores: vm.stores
                        )

                        VStack(spacing: 12) {
                            ForEach(vm.stores) { store in
                                NavigationLink {
                                    StoreDetailView(
                                        storeName: store.storeName ?? "Inconnu"
                                    )
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
