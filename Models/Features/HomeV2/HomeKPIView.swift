import SwiftUI

struct HomeKPIView: View {

    let monthTotal: Double
    let ticketCount: Int

    var body: some View {
        HStack(spacing: 12) {

            kpiCard(
                title: "Ce mois",
                value: String(format: "%.2f €", monthTotal),
                icon: "calendar"
            )

            kpiCard(
                title: "Tickets",
                value: "\(ticketCount)",
                icon: "doc.text"
            )
        }
    }

    private func kpiCard(title: String, value: String, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(Color(Theme.primaryBlue))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }
}
