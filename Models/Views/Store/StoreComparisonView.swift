import SwiftUI
import CoreData

struct StoreComparisonView: View {

    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = StoreComparisonViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    insights

                    // 🍩 DONUT
                    if !vm.comparisons.isEmpty {
                        StoreComparisonDonutView(
                            items: vm.comparisons,
                            total: vm.grandTotal
                        )
                    }

                    // 📊 BAR CHART
                    if !vm.comparisons.isEmpty {
                        StoreComparisonBarChartView(
                            items: vm.comparisons
                        )
                    }

                    // 📋 LISTE
                    VStack(spacing: 12) {
                        ForEach(vm.comparisons) { item in
                            comparisonRow(item)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Comparaison")
            .onAppear {
                vm.load(context: context)
            }
        }
    }

    // MARK: - Insights
    private var insights: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Analyse rapide")
                .font(.headline)

            if let max = vm.highestStore {
                Text("🥇 Plus élevé : \(max.storeName) — \(format(max.total))")
            }

            if let min = vm.lowestStore {
                Text("🥉 Plus bas : \(min.storeName) — \(format(min.total))")
            }

            if vm.delta > 0 {
                Text("📊 Écart : \(format(vm.delta))")
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    // MARK: - Row
    private func comparisonRow(_ item: StoreComparisonItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {

            HStack {
                Text(item.storeName)
                    .font(.headline)

                Spacer()

                Text(format(item.total))
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }

            ProgressView(value: item.percentOfTotal / 100)
                .tint(.blue)

            Text(
                "\(item.ticketCount) ticket(s) • \(String(format: "%.1f", item.percentOfTotal)) %"
            )
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    private func format(_ value: Double) -> String {
        String(format: "%.2f €", value)
    }
}
