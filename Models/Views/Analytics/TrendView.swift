import SwiftUI
import Charts

/// Courbe unique des dépenses sur 6 mois — aucun filtre, aucune comparaison,
/// aucun zoom. Répond à une seule question : « mes dépenses évoluent-elles ? »
struct TrendView: View {

    let points: [MonthlyTrendPoint]

    var body: some View {
        Chart(points) { point in
            AreaMark(
                x: .value("Mois", point.month),
                y: .value("Total", point.total)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [Theme.primaryBlue.opacity(0.18), Theme.primaryBlue.opacity(0.02)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )

            LineMark(
                x: .value("Mois", point.month),
                y: .value("Total", point.total)
            )
            .foregroundStyle(Theme.primaryBlue)
            .lineStyle(StrokeStyle(lineWidth: 2.5, lineCap: .round))

            PointMark(
                x: .value("Mois", point.month),
                y: .value("Total", point.total)
            )
            .foregroundStyle(Theme.primaryBlue)
            .symbolSize(40)
        }
        .chartXAxis {
            AxisMarks { _ in
                AxisValueLabel()
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                    .foregroundStyle(Color(.systemFill))
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(String(format: "%.0f", amount))
                    }
                }
                .font(.caption2)
                .foregroundStyle(Color.secondary)
            }
        }
        .frame(height: 180)
    }
}
