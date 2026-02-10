import SwiftUI
import CoreData

struct StoreDetailView: View {

    // MARK: - Input
    let storeName: String

    // MARK: - CoreData
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    // MARK: - Tickets du magasin
    private var storeTickets: [Ticket] {
        tickets.filter { $0.storeName == storeName }
    }

    // MARK: - KPI
    private var totalAmount: Double {
        storeTickets.reduce(0) { $0 + $1.amount }
    }

    private var ticketCount: Int {
        storeTickets.count
    }

    private var averageBasket: Double {
        guard ticketCount > 0 else { return 0 }
        return totalAmount / Double(ticketCount)
    }

    // MARK: - Comparaison mensuelle
    private var thisMonthTotal: Double {
        let cal = Calendar.current
        let start = cal.date(from: cal.dateComponents([.year, .month], from: Date()))!
        let startMs = Int64(start.timeIntervalSince1970 * 1000)

        return storeTickets
            .filter { $0.dateMillis >= startMs }
            .reduce(0) { $0 + $1.amount }
    }

    private var lastMonthTotal: Double {
        let cal = Calendar.current
        let startThisMonth = cal.date(from: cal.dateComponents([.year, .month], from: Date()))!
        let startLastMonth = cal.date(byAdding: .month, value: -1, to: startThisMonth)!

        let startMs = Int64(startLastMonth.timeIntervalSince1970 * 1000)
        let endMs = Int64(startThisMonth.timeIntervalSince1970 * 1000)

        return storeTickets
            .filter { $0.dateMillis >= startMs && $0.dateMillis < endMs }
            .reduce(0) { $0 + $1.amount }
    }

    private var variationPercent: Double {
        guard lastMonthTotal > 0 else { return 0 }
        return ((thisMonthTotal - lastMonthTotal) / lastMonthTotal) * 100
    }

    // MARK: - Groupement par jour (FIXED)
    private var groupedByDay: [(date: Date, total: Double)] {
        let calendar = Calendar.current

        let grouped: [Date: [Ticket]] = Dictionary(
            grouping: storeTickets,
            by: { ticket in
                let date = Date(timeIntervalSince1970: TimeInterval(ticket.dateMillis) / 1000)
                return calendar.startOfDay(for: date)
            }
        )

        var result: [(Date, Double)] = []

        for (date, tickets) in grouped {
            let total = tickets.reduce(0) { $0 + $1.amount }
            result.append((date, total))
        }

        return result.sorted { $0.0 < $1.0 }
    }

    // MARK: - Top catégories (FIXED)
    private var categoryTotals: [(name: String, total: Double)] {
        let grouped: [String: [Ticket]] = Dictionary(
            grouping: storeTickets,
            by: { $0.category }
        )

        var result: [(String, Double)] = []

        for (category, tickets) in grouped {
            let total = tickets.reduce(0) { $0 + $1.amount }
            result.append((category, total))
        }

        return result
            .sorted { $0.1 > $1.1 }
            .prefix(3)
            .map { $0 }
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                headerView

                if !groupedByDay.isEmpty {
                    StoreBarChartView(data: groupedByDay)
                }

                if !categoryTotals.isEmpty {
                    topCategoriesView
                }

                ticketListView
            }
            .padding(.bottom, 24)
        }
        .navigationTitle(storeName)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Header
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(storeName)
                .font(.title2.bold())

            Text(String(format: "%.2f €", totalAmount))
                .font(.largeTitle.bold())
                .foregroundColor(Color(Theme.primaryBlue))

            HStack {
                Text("\(ticketCount) tickets")
                Spacer()
                Text(String(format: "Panier moyen %.2f €", averageBasket))
            }
            .font(.caption)
            .foregroundColor(.secondary)

            HStack {
                Text("Ce mois")
                Spacer()
                Text(String(format: "%.2f €", thisMonthTotal))
            }

            HStack {
                Text("Variation")
                Spacer()
                Text(String(format: "%+.1f %%", variationPercent))
                    .foregroundColor(variationPercent >= 0 ? .green : .red)
            }
            .font(.caption)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    // MARK: - Top catégories
    private var topCategoriesView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Top catégories")
                .font(.headline)
                .padding(.horizontal)

            ForEach(categoryTotals, id: \.name) { cat in
                HStack {
                    Text(cat.name)
                    Spacer()
                    Text(String(format: "%.2f €", cat.total))
                        .foregroundColor(Color(Theme.primaryBlue))
                }
                .padding()
                .background(Color(.secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Tickets
    private var ticketListView: some View {
        VStack(spacing: 12) {
            ForEach(storeTickets, id: \.objectID) { ticket in
                NavigationLink {
                    TicketDetailView(ticket: ticket)
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(ticket.storeName)
                                .font(.headline)

                            Spacer()

                            Text(String(format: "%.2f €", ticket.amount))
                                .foregroundColor(Color(Theme.primaryBlue))
                                .fontWeight(.semibold)
                        }

                        Text(ticket.category)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(DateUtils.shortString(fromMillis: ticket.dateMillis))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}
