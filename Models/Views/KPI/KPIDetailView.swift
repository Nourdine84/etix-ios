import SwiftUI
import CoreData

struct KPIDetailView: View {

    let type: KPIType

    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    // MARK: - Filtered tickets (selon KPI)

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
            let start = calendar.date(from: comps) ?? now
            let startMs = Int64(start.timeIntervalSince1970 * 1000)
            return tickets.filter { $0.dateMillis >= startMs }

        case .all:
            return Array(tickets)
        }
    }

    // MARK: - KPI values

    private var totalAmount: Double {
        filteredTickets.reduce(0) { $0 + $1.amount }
    }

    // MARK: - Group tickets by day

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

    // MARK: - Chart data (bar chart)

    private var chartData: [(date: Date, total: Double)] {
        groupedTickets.map { section in
            (
                date: section.date,
                total: section.items.reduce(0) { $0 + $1.amount }
            )
        }
    }

    // MARK: - Donut data (categories)

    private var donutSlices: [KPIDonutChartView.Slice] {
        let grouped = Dictionary(grouping: filteredTickets) { ticket in
            let cat = ticket.category.trimmingCharacters(in: .whitespacesAndNewlines)
            return cat.isEmpty ? "Autre" : cat
        }

        let palette: [Color] = [
            .blue, .green, .orange, .purple, .red, .teal, .pink, .indigo
        ]

        return grouped
            .map { key, items in
                KPIDonutChartView.Slice(
                    name: key,
                    value: items.reduce(0) { $0 + $1.amount },
                    color: palette.randomElement() ?? .blue
                )
            }
            .sorted { $0.value > $1.value }
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
            VStack(spacing: 28) {

                // 🔵 KPI HEADER
                KPIHeaderView(
                    title: type.title,
                    total: totalAmount,
                    ticketCount: filteredTickets.count
                )
                .padding(.top, 8)

                // 📊 BAR CHART
                if !chartData.isEmpty {
                    KPIBarChartView(data: chartData)
                }

                // 🍩 DONUT PAR CATÉGORIE
                if donutSlices.count > 1 {
                    KPIDonutChartView(
                        slices: donutSlices,
                        total: totalAmount
                    )
                }

                // 📄 LISTE DES TICKETS
                if groupedTickets.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 22) {
                        ForEach(groupedTickets, id: \.date) { section in
                            VStack(alignment: .leading, spacing: 10) {

                                // Header jour
                                HStack {
                                    Text(sectionTitle(for: section.date))
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(.secondary)

                                    if Calendar.current.isDateInToday(section.date) {
                                        Text("Aujourd’hui")
                                            .font(.caption.bold())
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color(Theme.primaryBlue).opacity(0.15))
                                            .foregroundColor(Color(Theme.primaryBlue))
                                            .cornerRadius(8)
                                    }

                                    Spacer()
                                }
                                .padding(.horizontal)

                                // Tickets du jour
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
            .padding(.bottom, 32)
        }
        .navigationTitle(type.title)
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
