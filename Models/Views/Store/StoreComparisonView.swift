import SwiftUI
import CoreData

struct StoreComparisonView: View {

    @Environment(\.managedObjectContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

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

    var body: some View {
        NavigationStack {
            ZStack {

                DesignSystem.premiumBackground(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 36) {

                        headerSection
                            .premiumAppear()

                        if totalAmount > 0 {
                            donutSection
                                .premiumAppear()

                            storeList
                                .premiumAppear()
                        } else {
                            emptyState
                        }
                    }
                    .padding(.horizontal, DesignSystem.horizontalPadding)
                    .padding(.vertical, 40)
                }
            }
            .navigationTitle("Comparaison")
            .navigationBarTitleDisplayMode(.large)
            .animation(.easeInOut(duration: 0.25), value: colorScheme)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Total global")
                .font(.subheadline)
                .foregroundColor(.secondary)

            AnimatedAmountText(value: totalAmount)
                .font(.system(size: 36, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Theme.primaryBlue,
                            Theme.primaryBlue.opacity(0.85)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("\(groupedData.count) magasin(s)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .premiumCard()
    }

    private var donutSection: some View {

        let slices = generateSlices()

        return ZStack {

            ForEach(slices) { slice in
                DonutSliceView(slice: slice)
            }

            VStack(spacing: 4) {
                Text("Répartition")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(String(format: "%.0f €", totalAmount))
                    .font(.headline)
            }
        }
        .frame(height: 220)
        .premiumCard()
    }

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
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Theme.primaryBlue,
                                Theme.primaryBlue.opacity(0.85)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .fontWeight(.semibold)
            }

            ProgressView(value: percentage, total: 100)
                .tint(Theme.primaryBlue)

            Text("\(item.count) ticket(s) • \(String(format: "%.1f %%", percentage))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .premiumCard()
    }

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

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2")
                .font(.system(size: 44))
                .foregroundColor(.gray)

            Text("Aucune donnée disponible")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 100)
    }
}
