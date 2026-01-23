import SwiftUI

struct KPIInsightsView: View {

    let tickets: [Ticket]

    private var total: Double {
        tickets.reduce(0) { $0 + $1.amount }
    }

    private var average: Double {
        tickets.isEmpty ? 0 : total / Double(tickets.count)
    }

    private var topCategory: (name: String, total: Double)? {
        let grouped = Dictionary(grouping: tickets) { $0.category }
        return grouped
            .map { (key, items) in
                (key.isEmpty ? "Autre" : key,
                 items.reduce(0) { $0 + $1.amount })
            }
            .sorted { $0.1 > $1.1 }
            .first
    }

    private var highestTicket: Ticket? {
        tickets.max(by: { $0.amount < $1.amount })
    }

    private var mostExpensiveDay: (date: Date, total: Double)? {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: tickets) { ticket in
            let date = Date(timeIntervalSince1970: TimeInterval(ticket.dateMillis) / 1000)
            return calendar.startOfDay(for: date)
        }

        return grouped
            .map { (date, items) in
                (date, items.reduce(0) { $0 + $1.amount })
            }
            .sorted { $0.total > $1.total }
            .first
    }

    var body: some View {
        VStack(spacing: 12) {

            insightRow(
                title: "Dépense moyenne",
                value: String(format: "%.2f €", average),
                icon: "chart.bar"
            )

            if let cat = topCategory {
                insightRow(
                    title: "Catégorie principale",
                    value: "\(cat.name) — \(String(format: "%.2f €", cat.total))",
                    icon: "tag.fill"
                )
            }

            if let high = highestTicket {
                insightRow(
                    title: "Plus grosse dépense",
                    value: "\(String(format: "%.2f €", high.amount)) — \(high.storeName)",
                    icon: "arrow.up.circle.fill"
                )
            }

            if let day = mostExpensiveDay {
                insightRow(
                    title: "Jour le plus coûteux",
                    value: "\(DateFormatter.localizedString(from: day.date, dateStyle: .medium, timeStyle: .none)) — \(String(format: "%.2f €", day.total))",
                    icon: "calendar.badge.exclamationmark"
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    private func insightRow(title: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(Color(Theme.primaryBlue))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text(value)
                    .font(.subheadline.weight(.semibold))
            }

            Spacer()
        }
    }
}
