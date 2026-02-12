import SwiftUI
import Charts

struct StoreComparisonBarChartView: View {

    let items: [StoreComparisonItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Répartition par magasin")
                .font(.headline)
                .padding(.horizontal)

            Chart {
                ForEach(items) { item in
                    BarMark(
                        x: .value("Magasin", item.storeName),
                        y: .value("Total", item.total)
                    )
                    .foregroundStyle(.blue)
                }
            }
            .frame(height: 220)
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
