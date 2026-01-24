import SwiftUI
import Charts

struct StoreComparisonBarChartView: View {

    let stores: [StoreTotal]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Comparaison des magasins")
                .font(.headline)
                .padding(.horizontal)

            Chart {
                ForEach(stores) { store in
                    BarMark(
                        x: .value("Magasin", store.storeName ?? "Inconnu"),
                        y: .value("Total", store.total)
                    )
                    .foregroundStyle(Color(Theme.primaryBlue))
                }
            }
            .frame(height: 240)
            .padding(.horizontal)
        }
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}
