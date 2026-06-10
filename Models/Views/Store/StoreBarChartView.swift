import SwiftUI
import Charts

struct StoreBarChartView: View {

    let data: [(date: Date, total: Double)]

    var body: some View {
        Chart {
            ForEach(data, id: \.date) { item in
                BarMark(
                    x: .value("Date", item.date),
                    y: .value("Montant", item.total)
                )
                .foregroundStyle(Theme.primaryBlue)
            }
        }
        .frame(height: 200)
    }
}
