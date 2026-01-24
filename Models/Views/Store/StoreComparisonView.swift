import SwiftUI

struct StoreComparisonView: View {

    @Environment(\.managedObjectContext) private var context
    @StateObject private var vm = StoreComparisonViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {

                    // 🔝 HEADER
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Comparaison des magasins")
                            .font(.title2.bold())

                        Text(String(format: "%.2f € au total", vm.grandTotal))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)

                    // 📊 LISTE COMPARATIVE
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

    // MARK: - Row
    private func comparisonRow(_ item: StoreComparison) -> some View {
        HStack {

            // 🏅 RANG
            Text("\(item.rank)")
                .font(.headline)
                .frame(width: 28)
                .foregroundColor(item.rank <= 3 ? .white : .secondary)
                .background(item.rank <= 3 ? Color(Theme.primaryBlue) : .clear)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(item.storeName)
                    .font(.headline)

                Text("\(item.ticketCount) ticket(s) • \(String(format: "%.1f", item.percent)) %")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Text(String(format: "%.2f €", item.total))
                .fontWeight(.semibold)
                .foregroundColor(Color(Theme.primaryBlue))
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }
}
