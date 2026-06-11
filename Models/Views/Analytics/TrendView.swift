import SwiftUI
import Charts

/// Courbe unique des dépenses sur 6 mois — aucun filtre, aucune comparaison,
/// aucun zoom. Répond à une seule question : « mes dépenses évoluent-elles ? »
struct TrendView: View {

    let points: [MonthlyTrendPoint]

    var body: some View {
        Chart(points) { point in
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
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                    .foregroundStyle(Color(.systemFill))
                AxisValueLabel(format: .number.precision(.fractionLength(0)))
                    .font(.caption2)
                    .foregroundStyle(Color.secondary)
            }
        }
        .frame(height: 180)
    }
}
