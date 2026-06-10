import SwiftUI
import CoreData

struct StoreComparisonView: View {

    let initialRange: TimeRange

    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = StoreComparisonViewModel()

    @State private var range: TimeRange

    init(initialRange: TimeRange) {
        self.initialRange = initialRange
        _range = State(initialValue: initialRange)
    }

    var body: some View {
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

            ScrollView {
                VStack(spacing: 24) {

                    insights

                    if !vm.comparisons.isEmpty {
                        StoreComparisonDonutView(
                            items: vm.comparisons,
                            total: vm.grandTotal
                        )
                    }

                    if !vm.comparisons.isEmpty {
                        StoreComparisonBarChartView(
                            items: vm.comparisons
                        )
                    }

                    if vm.comparisons.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: 12) {
                            ForEach(vm.comparisons) { item in
                                comparisonRow(item)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .scrollIndicators(.hidden)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Comparaison")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            vm.load(context: context, range: range)
        }
        .onChange(of: range) { _, _ in
            vm.load(context: context, range: range)
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

            if let min = vm.lowestStore, vm.comparisons.count > 1 {
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
                    .foregroundColor(Theme.primaryBlue)
            }

            ProgressView(value: item.percentOfTotal / 100)
                .tint(Theme.primaryBlue)

            let count = item.ticketCount
            Text("\(count) ticket\(count > 1 ? "s" : "") • \(String(format: "%.1f", item.percentOfTotal)) %")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("Aucun magasin sur cette période")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func format(_ value: Double) -> String {
        String(format: "%.2f €", value)
    }
}
