import SwiftUI
import CoreData

struct CategoryDetailView: View {

    // MARK: - Input
    let categoryName: String

    // MARK: - CoreData
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    // MARK: - Tickets catégorie
    private var categoryTickets: [Ticket] {
        tickets.filter { $0.category == categoryName }
    }

    // MARK: - Totaux
    private var totalAmount: Double {
        categoryTickets.reduce(0) { $0 + $1.amount }
    }

    // MARK: - Groupement par jour
    private var groupedByDay: [(date: Date, items: [Ticket])] {
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: categoryTickets) { ticket -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(ticket.dateMillis) / 1000)
            return calendar.startOfDay(for: date)
        }

        return grouped
            .map { ($0.key, $0.value) }
            .sorted { $0.date > $1.date }
    }

    // MARK: - Données graphique
    private var chartData: [(date: Date, total: Double)] {
        groupedByDay.map {
            ($0.date, $0.items.reduce(0) { $0 + $1.amount })
        }
        .sorted { $0.date < $1.date }
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // 🔵 HEADER
                VStack(alignment: .leading, spacing: 6) {
                    Text(categoryName)
                        .font(.title2.bold())

                    Text(String(format: "%.2f €", totalAmount))
                        .font(.title.bold())
                        .foregroundColor(Color(Theme.primaryBlue))

                    Text("\(categoryTickets.count) ticket(s)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .padding(.horizontal)

                // 📊 GRAPH
                if !chartData.isEmpty {
                    CategoryBarChartView(data: chartData)
                }

                // 📄 LISTE
                if groupedByDay.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 20) {
                        ForEach(groupedByDay, id: \.date) { section in
                            VStack(alignment: .leading, spacing: 10) {

                                Text(sectionTitle(section.date))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal)

                                VStack(spacing: 10) {
                                    ForEach(section.items, id: \.objectID) { ticket in
                                        NavigationLink {
                                            TicketDetailView(ticket: ticket)
                                        } label: {
                                            ticketRow(ticket)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, 24)
        }
        .navigationTitle("Détails")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Helpers
    private func sectionTitle(_ date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Aujourd’hui" }
        if cal.isDateInYesterday(date) { return "Hier" }

        return DateFormatter.localizedString(
            from: date,
            dateStyle: .medium,
            timeStyle: .none
        )
    }

    // MARK: - Row
    private func ticketRow(_ t: Ticket) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(t.storeName)
                    .font(.headline)

                Spacer()

                Text(String(format: "%.2f €", t.amount))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(Theme.primaryBlue))
            }

            Text(DateUtils.shortString(fromMillis: t.dateMillis))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    // MARK: - Empty
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.gray)

            Text("Aucun ticket")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
