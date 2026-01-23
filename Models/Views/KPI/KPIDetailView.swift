import SwiftUI
import CoreData

struct KPIDetailView: View {

    // MARK: - Input
    let type: KPIType

    // MARK: - CoreData
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    // MARK: - Tickets filtrés (période courante)
    private var filteredTickets: [Ticket] {
        let now = Date()
        let calendar = Calendar.current

        switch type {
        case .today:
            let start = calendar.startOfDay(for: now)
            let startMs = Int64(start.timeIntervalSince1970 * 1000)
            return tickets.filter { $0.dateMillis >= startMs }

        case .month:
            let comps = calendar.dateComponents([.year, .month], from: now)
            guard let start = calendar.date(from: comps) else { return [] }
            let startMs = Int64(start.timeIntervalSince1970 * 1000)
            return tickets.filter { $0.dateMillis >= startMs }

        case .all:
            return Array(tickets)
        }
    }

    // MARK: - Totaux
    private var totalAmount: Double {
        filteredTickets.reduce(0) { $0 + $1.amount }
    }

    private var previousTotal: Double {
        let now = Date()
        let calendar = Calendar.current

        switch type {

        case .today:
            let startToday = calendar.startOfDay(for: now)
            let startYesterday = calendar.date(byAdding: .day, value: -1, to: startToday)!
            let endYesterday = startToday

            let startMs = Int64(startYesterday.timeIntervalSince1970 * 1000)
            let endMs = Int64(endYesterday.timeIntervalSince1970 * 1000)

            return tickets
                .filter { $0.dateMillis >= startMs && $0.dateMillis < endMs }
                .reduce(0) { $0 + $1.amount }

        case .month:
            let comps = calendar.dateComponents([.year, .month], from: now)
            let startThisMonth = calendar.date(from: comps)!
            let startLastMonth = calendar.date(byAdding: .month, value: -1, to: startThisMonth)!

            let startMs = Int64(startLastMonth.timeIntervalSince1970 * 1000)
            let endMs = Int64(startThisMonth.timeIntervalSince1970 * 1000)

            return tickets
                .filter { $0.dateMillis >= startMs && $0.dateMillis < endMs }
                .reduce(0) { $0 + $1.amount }

        case .all:
            return 0
        }
    }

    private var variationPercent: Double {
        guard previousTotal > 0 else { return 0 }
        return ((totalAmount - previousTotal) / previousTotal) * 100
    }

    // MARK: - Groupement par jour
    private var groupedTickets: [(date: Date, items: [Ticket])] {
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: filteredTickets) { ticket -> Date in
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

                KPIHeaderView(
                    title: type.title,
                    total: totalAmount,
                    ticketCount: filteredTickets.count,
                    variation: variationPercent
                )

                KPIInsightsView(tickets: filteredTickets)

                if !groupedTickets.isEmpty {
                    KPIBarChartView(
                        data: groupedTickets.map {
                            ($0.date, $0.items.reduce(0) { $0 + $1.amount })
                        }
                    )
                }

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
        .navigationTitle(type.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                KPIExportButton(
                    type: type,
                    tickets: filteredTickets,
                    total: totalAmount,
                    variation: variationPercent
                )
            }
        }
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

            Text(t.category)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(DateUtils.shortString(fromMillis: t.dateMillis))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 42))
                .foregroundColor(.gray)

            Text("Aucun ticket disponible")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
