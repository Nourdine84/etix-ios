import SwiftUI

struct LastTicketRow: View {

    let ticket: Ticket

    var body: some View {
        HStack(spacing: 12) {

            Image(systemName: "receipt")
                .font(.system(size: 20))
                .foregroundColor(Color(Theme.primaryBlue))

            VStack(alignment: .leading, spacing: 4) {

                Text(ticket.storeName ?? "Magasin")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(ticket.category.isEmpty ? "Autre" : ticket.category)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {

                Text(String(format: "%.2f €", ticket.amount))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(Theme.primaryBlue))

                Text(formattedDate(ticket.dateMillis))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private func formattedDate(_ ms: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(ms) / 1000)
        let df = DateFormatter()
        df.dateStyle = .short
        return df.string(from: date)
    }
}
