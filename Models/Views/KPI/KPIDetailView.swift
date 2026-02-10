import SwiftUI
import CoreData

struct KPIDetailView: View {

    // MARK: - Input
    let type: KPIType
    let range: TimeRange

    // MARK: - CoreData
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    // MARK: - Current range tickets
    private var currentTickets: [Ticket] {
        let range = DateRangeHelper.currentRange(for: range)
        let startMs = DateRangeHelper.millis(range.start)
        let endMs = DateRangeHelper.millis(range.end)

        return tickets.filter {
            $0.dateMillis >= startMs && $0.dateMillis < endMs
        }
    }

    // MARK: - Previous range tickets
    private var previousTickets: [Ticket] {
        let range = DateRangeHelper.previousRange(for: range)
        let startMs = DateRangeHelper.millis(range.start)
        let endMs = DateRangeHelper.millis(range.end)

        return tickets.filter {
            $0.dateMillis >= startMs && $0.dateMillis < endMs
        }
    }

    // MARK: - Totals
    private var totalAmount: Double {
        currentTickets.reduce(0) { $0 + $1.amount }
    }

    private var previousTotal: Double {
        previousTickets.reduce(0) { $0 + $1.amount }
    }

    private var variationPercent: Double {
        guard previousTotal > 0 else { return 0 }
        return ((totalAmount - previousTotal) / previousTotal) * 100
    }

    // MARK: - Grouped by day
    private var groupedTickets: [(date: Date, items: [Ticket])] {
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: currentTickets) { ticket -> Date in
            let date = Date(
                timeIntervalSince1970: TimeInterval(ticket.dateMillis) / 1000
            )
            return calendar.startOfDay(for: date)
        }

        return grouped
            .map { ($0.key, $0.value) }
            .sorted { $0.date > $1.date }
    }

    // MARK: - Helpers
    private func sectionTitle(for date: Date) -> String {
        let cal = Calendar.current
        if cal.isDateInToday(date) { return "Aujourd’hui" }
        if cal.isDateInYesterday(date) { return "Hier" }

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
                KPIHeaderView(
                    title: type.title,
                    total: totalAmount,
                    ticketCount: currentTickets.count,
                    variation: variationPercent
                )

                // 🧠 INSIGHTS
                KPIInsightsView(tickets: currentTickets)

                // 📊 GRAPH
                if !groupedTickets.isEmpty {
                    KPIBarChartView(
                        data: groupedTickets.map {
                            ($0.date, $0.items.reduce(0) { $0 + $1.amount })
                        }
                    )
                }

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
        .navigationTitle(type.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                KPIExportButton(
                    type: type,
                    tickets: currentTickets,
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

    // MARK: - Empty
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
