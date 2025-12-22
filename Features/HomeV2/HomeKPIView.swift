import SwiftUI

struct HomeKPIView: View {

    let total: Double
    let count: Int
    let month: Double

    var body: some View {
        VStack(spacing: 16) {
            kpiCard(
                title: "Total dépenses",
                value: total,
                color: .blue
            )

            HStack(spacing: 16) {
                kpiMini(
                    title: "Tickets",
                    value: "\(count)",
                    color: .purple
                )

                kpiMini(
                    title: "Ce mois",
                    value: "\(month, specifier: "%.2f") €",
                    color: .green
                )
            }
        }
    }

    private func kpiCard(title: String, value: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("\(value, specifier: "%.2f") €")
                .font(.largeTitle)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.15))
        .cornerRadius(16)
    }

    private func kpiMini(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.15))
        .cornerRadius(14)
    }
}
