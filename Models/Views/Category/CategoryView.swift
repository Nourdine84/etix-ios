import SwiftUI
import CoreData

struct CategoryView: View {

    @Environment(\.managedObjectContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    private var groupedData: [(category: String, total: Double)] {
        let grouped = Dictionary(grouping: tickets) { $0.category }
        return grouped
            .map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.1 > $1.1 }
    }

    private var totalAmount: Double {
        groupedData.reduce(0) { $0 + $1.1 }
    }

    var body: some View {
        NavigationStack {
            ZStack {

                DesignSystem.premiumBackground(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignSystem.verticalSpacing) {

                        headerSection
                            .premiumAppear()

                        if totalAmount > 0 {
                            donutSection
                            categoryList
                        } else {
                            emptyState
                        }
                    }
                    .padding(.horizontal, DesignSystem.horizontalPadding)
                    .padding(.vertical, 40)
                }
            }
            .navigationTitle("Catégories")
            .navigationBarTitleDisplayMode(.large)
            .animation(.easeInOut(duration: 0.25), value: colorScheme)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("TOTAL DÉPENSES")
                .font(.caption)
                .textCase(.uppercase)
                .tracking(1)
                .foregroundColor(.secondary)

            AnimatedAmountText(value: totalAmount)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .kerning(-0.5)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.primaryBlue, Theme.primaryBlue.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .premiumCard()
    }

    private var donutSection: some View {
        ZStack {
            ForEach(generateSlices()) { slice in
                DonutSliceView(slice: slice)
            }

            Text(String(format: "%.0f €", totalAmount))
                .font(.headline)
        }
        .frame(height: 220)
        .premiumCard()
    }

    private var categoryList: some View {
        VStack(spacing: 16) {
            ForEach(groupedData, id: \.category) { item in
                categoryRow(item)
            }
        }
    }

    private func categoryRow(_ item: (category: String, total: Double)) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text(item.category)
                    .font(.headline)

                Spacer()

                Text(String(format: "%.2f €", item.total))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
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
        VStack(spacing: 20) {
            Image(systemName: "chart.pie")
                .font(.system(size: 44))
                .foregroundColor(.gray)

            Text("Aucune donnée disponible")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 120)
    }
}
