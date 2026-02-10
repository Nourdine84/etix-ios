import SwiftUI

struct StoreComparisonView: View {

    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = StoreComparisonViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    header

                    if !vm.comparisons.isEmpty {
                        StoreComparisonBarChartView(items: vm.comparisons)
                            .padding(.horizontal)
                    }

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

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Comparaison des magasins")
                .font(.title2.bold())

            Text(String(format: "%.2f € au total", vm.grandTotal))
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }

    private func comparisonRow(_ item: StoreComparisonItem) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.storeName)
                    .font(.headline)

                Text("\(item.ticketCount) ticket(s)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text(String(format: "%.2f €", item.total))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(Theme.primaryBlue))

                Text(String(format: "%.1f %%", item.sharePercent))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}
