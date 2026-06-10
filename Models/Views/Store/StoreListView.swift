import SwiftUI
import CoreData

struct StoreListView: View {

    let categoryName: String?

    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = StoreListViewModel()

    @State private var range: TimeRange = AppSettings.load().defaultRange

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                Picker("Période", selection: $range) {
                    ForEach(TimeRange.allCases) { r in
                        Text(r.title).tag(r)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color(.systemGroupedBackground))

                ZStack {
                    Color(.systemGroupedBackground).ignoresSafeArea()

                    if vm.stores.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(Array(vm.stores.enumerated()), id: \.element.id) { index, store in
                                    NavigationLink {
                                        StoreDetailView(storeName: store.storeName ?? "Inconnu")
                                    } label: {
                                        storeCard(store, rank: index + 1)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                        }
                        .scrollIndicators(.hidden)
                    }
                }
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Magasins")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        StoreComparisonView(initialRange: range)
                    } label: {
                        Image(systemName: "chart.bar.fill")
                    }
                }
            }
            .onAppear {
                vm.load(categoryName: categoryName ?? "", context: context, range: range)
            }
            .onChange(of: range) { _, _ in
                vm.load(categoryName: categoryName ?? "", context: context, range: range)
            }
        }
    }

    // MARK: - Store Card

    private func storeCard(_ store: StoreTotal, rank: Int) -> some View {
        let sharePercent = vm.grandTotal > 0 ? (store.total / vm.grandTotal * 100) : 0
        let average = store.ticketCount > 0 ? store.total / Double(store.ticketCount) : 0

        return VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    if rank <= 3 {
                        Text("N°\(rank)")
                            .font(.caption2.weight(.bold))
                            .tracking(1)
                            .foregroundColor(rank == 1 ? Theme.primaryBlue : .secondary)
                    }
                    Text(store.storeName ?? "Inconnu")
                        .font(.headline)
                        .foregroundColor(.primary)
                }
                Spacer()
                Text(String(format: "%.2f €", store.total))
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.primaryBlue, Theme.primaryBlue.opacity(0.75)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            HStack(spacing: 6) {
                Text("\(store.ticketCount) ticket(s)")
                Text("·")
                Text(String(format: "%.2f €/visite", average))
                Text("·")
                Text(String(format: "%.0f%%", sharePercent))
            }
            .font(.caption)
            .foregroundColor(.secondary)

            Text(relativeLastVisit(store.lastPurchaseMillis))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "building.2")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("Aucun magasin sur cette période")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    // MARK: - Helpers

    private func relativeLastVisit(_ ms: Int64) -> String {
        guard ms > 0 else { return "—" }
        let date = Date(timeIntervalSince1970: Double(ms) / 1000)
        let days = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        switch days {
        case 0:  return "Dernier passage aujourd'hui"
        case 1:  return "Dernier passage hier"
        default: return "Dernier passage il y a \(days) jours"
        }
    }
}
