import SwiftUI
import CoreData

struct CategoryView: View {

    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    private var groupedData: [(category: String, total: Double)] {
        let grouped = Dictionary(grouping: tickets) { $0.category }

        return grouped
            .map { (key, value) in
                (key, value.reduce(0) { $0 + $1.amount })
            }
            .sorted { $0.total > $1.total }
    }

    private var totalAmount: Double {
        groupedData.reduce(0) { $0 + $1.total }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.premiumBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignSystem.verticalSpacing) {

                        headerSection

                        if totalAmount > 0 {
                            donutSection
                            categoryList
                        } else {
                            emptyState
                        }
                    }
                    .padding(.horizontal, DesignSystem.horizontalPadding)
                    .padding(.vertical)
                }
            }
            .navigationTitle("Catégories")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Total des dépenses")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(String(format: "%.2f €", totalAmount))
                .font(.system(size: 34, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumCard()
    }

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
        .premiumCard()
    }

    private var categoryList: some View {
        VStack(spacing: DesignSystem.innerSpacing) {
            ForEach(groupedData, id: \.category) { item in
                categoryRow(item)
            }
        }
    }

    private func categoryRow(_ item: (category: String, total: Double)) -> some View {

        let percentage = totalAmount > 0
            ? (item.total / totalAmount) * 100
            : 0

        return VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text(item.category)
                    .font(.headline)

                Spacer()

                Text(String(format: "%.2f €", item.total))
                    .foregroundColor(Theme.primaryBlue)
                    .fontWeight(.semibold)
            }

            ProgressView(value: percentage, total: 100)
                .tint(Theme.primaryBlue)

            Text(String(format: "%.1f %%", percentage))
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
                label: item.category,
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
            Image(systemName: "chart.pie")
                .font(.system(size: 44))
                .foregroundColor(.gray)

            Text("Aucune donnée disponible")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}
