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
        tickets
            .filter { $0.category == categoryName }
            .sorted { $0.dateMillis > $1.dateMillis }
    }

    // MARK: - Totaux
    private var totalAmount: Double {
        categoryTickets.reduce(0) { $0 + $1.amount }
    }

    private var ticketCount: Int {
        categoryTickets.count
    }

    // MARK: - Groupement par jour
    private var groupedTickets: [(date: Date, items: [Ticket])] {
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: categoryTickets) { ticket in
            let date = Date(timeIntervalSince1970: TimeInterval(ticket.dateMillis) / 1000)
            return calendar.startOfDay(for: date)
        }

        return grouped
            .map { ($0.key, $0.value) }
            .sorted { $0.date > $1.date }
    }

    // MARK: - Helpers
    private func sectionTitle(for date: Date) -> String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Aujourd’hui" }
        if calendar.isDateInYesterday(date) { return "Hier" }

        return DateFormatter.localizedString(
            from: date,
            dateStyle: .medium,
            timeStyle: .none
        )
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // 🔵 KPI HEADER
                VStack(alignment: .leading, spacing: 8) {
                    Text(categoryName)
                        .font(.headline)
                        .foregroundColor(.secondary)

                    Text(String(format: "%.2f €", totalAmount))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(Theme.primaryBlue))

                    Text("\(ticketCount) ticket\(ticketCount > 1 ? "s" : "")")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .padding(.horizontal)

                // 📄 LISTE
                if groupedTickets.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 20) {
                        ForEach(groupedTickets, id: \.date) { section in
                            VStack(alignment: .leading, spacing: 10) {

                                Text(sectionTitle(for: section.date))
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
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Ticket Row
    private func ticketRow(_ t: Ticket) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(t.storeName)
                    .font(.headline)

                Spacer()

                Text(String(format: "%.2f €", t.amount))
                    .foregroundColor(Color(Theme.primaryBlue))
                    .fontWeight(.semibold)
            }

            Text(DateUtils.shortString(fromMillis: t.dateMillis))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }

    // MARK: - Empty
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 42))
                .foregroundColor(.gray)

            Text("Aucun ticket pour cette catégorie")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
