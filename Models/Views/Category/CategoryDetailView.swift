import SwiftUI
import CoreData

struct CategoryDetailView: View {

    // MARK: - Input
    let categoryName: String

    // MARK: - CoreData
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    // MARK: - Tickets filtrés
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

    // MARK: - Chart Data
    private var chartData: [(date: Date, total: Double)] {
        groupedByDay
            .map { ($0.date, $0.items.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.date < $1.date }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {

                        headerCard

                        if !chartData.isEmpty {
                            CategoryBarChartView(data: chartData)
                                .padding(.horizontal)
                        }

                        if groupedByDay.isEmpty {
                            emptyState
                        } else {
                            LazyVStack(spacing: 22) {
                                ForEach(groupedByDay, id: \.date) { section in
                                    sectionView(section)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle(categoryName)
            .navigationBarTitleDisplayMode(.large)
            
        }
    }

    // MARK: - Header Premium
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text("Total")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(String(format: "%.2f €", totalAmount))
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Theme.primaryBlue)

            Text("\(categoryTickets.count) ticket(s)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        .padding(.horizontal)
        .padding(.top, 10)
    }

    // MARK: - Section View
    private func sectionView(_ section: (date: Date, items: [Ticket])) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(sectionTitle(section.date))
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal)

            VStack(spacing: 14) {
                ForEach(section.items, id: \.objectID) { ticket in
                    NavigationLink {
                        TicketDetailView(ticket: ticket)
                    } label: {
                        ticketCard(ticket)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }

    // MARK: - Ticket Card Premium
    private func ticketCard(_ t: Ticket) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            HStack {
                Text(t.storeName)
                    .font(.headline)

                Spacer()

                Text(String(format: "%.2f €", t.amount))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.primaryBlue)
            }

            Text(DateUtils.shortString(fromMillis: t.dateMillis))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .shadow(color: .black.opacity(0.04), radius: 6, y: 3)
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

    // MARK: - Empty
    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "tray")
                .font(.system(size: 42))
                .foregroundColor(.gray)

            Text("Aucun ticket dans cette catégorie")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
