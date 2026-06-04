import SwiftUI
import CoreData

struct StoreComparisonView: View {

    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    // MARK: - Grouped Data

    private var groupedData: [(store: String, total: Double, count: Int)] {

        let grouped = Dictionary(grouping: tickets) { $0.storeName }

        return grouped
            .map { (key, value) in
                (
                    key,
                    value.reduce(0) { $0 + $1.amount },
                    value.count
                )
            }
            .sorted { $0.total > $1.total }
    }

    private var totalAmount: Double {
        groupedData.reduce(0) { $0 + $1.total }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {

                LinearGradient(
                    colors: [
                        Theme.primaryBlue.opacity(0.05),
                        Color(.systemGroupedBackground)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {

                        headerSection

                        if totalAmount > 0 {
                            donutSection
                            storeList
                        } else {
                            emptyState
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Magasins")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Total global")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(String(format: "%.2f €", totalAmount))
                .font(.system(size: 34, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Donut

    private var donutSection: some View {

        let slices = generateSlices()

        return ZStack {

            ForEach(slices) { slice in
                DonutSliceView(slice: slice)
            }

            VStack {
                Text("Total")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(String(format: "%.0f €", totalAmount))
                    .font(.headline)
            }
        }
        .frame(height: 220)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, y: 5)
        )
    }

    // MARK: - Store List

    private var storeList: some View {
        VStack(spacing: 16) {

            ForEach(groupedData, id: \.store) { item in
                storeRow(item)
            }
        }
    }

    private func storeRow(
        _ item: (store: String, total: Double, count: Int)
    ) -> some View {

        let percentage = totalAmount > 0
            ? (item.total / totalAmount) * 100
            : 0

        return VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text(item.store)
                    .font(.headline)

                Spacer()

                Text(String(format: "%.2f €", item.total))
                    .foregroundColor(Theme.primaryBlue)
                    .fontWeight(.semibold)
            }

            ProgressView(value: percentage, total: 100)
                .tint(Theme.primaryBlue)

            Text("\(item.count) ticket(s) • \(String(format: "%.1f %%", percentage))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 22)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, y: 4)
        )
    }

    // MARK: - Donut Generator

    private func generateSlices() -> [DonutSlice] {

        var startAngle: Double = 0

        return groupedData.map { item in

            let ratio = item.total / totalAmount
            let endAngle = startAngle + ratio

            let slice = DonutSlice(
                id: UUID(),
                label: item.store,
                value: item.total,
                startAngle: startAngle,
                endAngle: endAngle
            )

            startAngle = endAngle

            return slice
        }
    }

    // MARK: - Empty

    private var emptyState: some View {
        VStack(spacing: 16) {

            Image(systemName: "building.2")
                .font(.system(size: 44))
                .foregroundColor(.gray)

            Text("Aucune donnée disponible")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}
