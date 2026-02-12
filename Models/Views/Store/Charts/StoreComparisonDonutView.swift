import SwiftUI

struct StoreComparisonDonutView: View {

    let items: [StoreComparisonItem]
    let total: Double

    private var slices: [DonutSlice] {
        guard total > 0 else { return [] }

        var start: Double = 0

        return items.map { item in
            let percent = item.total / total
            let slice = DonutSlice(
                id: item.id,
                label: item.storeName,
                value: item.total,
                startAngle: start,
                endAngle: start + percent
            )
            start += percent
            return slice
        }
    }

    var body: some View {
        VStack(spacing: 16) {

            Text("Répartition par magasin")
                .font(.headline)

            ZStack {
                ForEach(slices) { slice in
                    DonutSliceView(slice: slice)
                }

                VStack {
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(format(total))
                        .font(.headline)
                        .fontWeight(.bold)
                }
            }
            .frame(width: 220, height: 220)

            legend
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    // MARK: - Legend
    private var legend: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(items) { item in
                HStack {
                    Circle()
                        .fill(color(for: item.id))
                        .frame(width: 10, height: 10)

                    Text(item.storeName)
                        .font(.caption)

                    Spacer()

                    Text(String(format: "%.1f %%", item.percentOfTotal))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func color(for id: UUID) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .pink, .teal]
        return colors[abs(id.hashValue) % colors.count]
    }

    private func format(_ value: Double) -> String {
        String(format: "%.2f €", value)
    }
}
