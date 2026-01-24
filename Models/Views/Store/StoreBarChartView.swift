import SwiftUI
import Charts

struct StoreBarChartView: View {

    let data: [(date: Date, total: Double)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Évolution des dépenses")
                .font(.headline)
                .padding(.horizontal)

            Chart {
                ForEach(data, id: \.date) { item in
                    BarMark(
                        x: .value("Date", item.date),
                        y: .value("Montant", item.total)
                    )
                    .foregroundStyle(Color(Theme.primaryBlue))
                }
            }
            .frame(height: 200)
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
