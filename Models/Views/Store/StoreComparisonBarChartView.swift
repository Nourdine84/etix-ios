import SwiftUI
import Charts

struct StoreComparisonBarChartView: View {

    let items: [StoreComparisonItem]

    var body: some View {
        Chart {
            ForEach(items) { item in
                BarMark(
                    x: .value("Magasin", item.storeName),
                    y: .value("Total", item.total)
                )
                .foregroundStyle(Color(Theme.primaryBlue))
            }
        }
        .frame(height: 220)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}
