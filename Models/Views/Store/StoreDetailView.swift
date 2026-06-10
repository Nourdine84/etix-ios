import SwiftUI
import CoreData

struct StoreDetailView: View {

    let storeName: String

    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    // MARK: - Computed

    private var storeTickets: [Ticket] {
        tickets.filter { $0.storeName == storeName }
              .sorted { $0.dateMillis > $1.dateMillis }
    }

    private var totalAmount: Double {
        storeTickets.reduce(0) { $0 + $1.amount }
    }

    private var ticketCount: Int { storeTickets.count }

    private var averageBasket: Double {
        guard ticketCount > 0 else { return 0 }
        return totalAmount / Double(ticketCount)
    }

    private var thisMonthTotal: Double {
        let start = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date()))!
        let startMs = Int64(start.timeIntervalSince1970 * 1000)
        return storeTickets.filter { $0.dateMillis >= startMs }.reduce(0) { $0 + $1.amount }
    }

    private var lastMonthTotal: Double {
        let cal = Calendar.current
        let startThis = cal.date(from: cal.dateComponents([.year, .month], from: Date()))!
        let startLast = cal.date(byAdding: .month, value: -1, to: startThis)!
        let startMs = Int64(startLast.timeIntervalSince1970 * 1000)
        let endMs = Int64(startThis.timeIntervalSince1970 * 1000)
        return storeTickets.filter { $0.dateMillis >= startMs && $0.dateMillis < endMs }.reduce(0) { $0 + $1.amount }
    }

    private var variationPercent: Double {
        guard lastMonthTotal > 0 else { return 0 }
        return ((thisMonthTotal - lastMonthTotal) / lastMonthTotal) * 100
    }

    private var lastVisitLabel: String {
        guard let last = storeTickets.first else { return "—" }
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.dateStyle = .medium
        return f.string(from: Date(timeIntervalSince1970: Double(last.dateMillis) / 1000))
    }

    private var avgDaysBetweenVisits: Int? {
        guard storeTickets.count >= 2 else { return nil }
        let sorted = storeTickets.map { $0.dateMillis }.sorted()
        let spanDays = Int((Double(sorted.last! - sorted.first!) / 1000 / 86400).rounded())
        return max(1, spanDays / (storeTickets.count - 1))
    }

    private var lastPurchaseInfo: (date: String, amount: Double, category: String)? {
        guard let ticket = storeTickets.first else { return nil }
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.dateStyle = .long
        f.timeStyle = .none
        return (
            date: f.string(from: Date(timeIntervalSince1970: Double(ticket.dateMillis) / 1000)),
            amount: ticket.amount,
            category: ticket.category
        )
    }

    private var groupedByDay: [(date: Date, total: Double)] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: storeTickets) { ticket in
            cal.startOfDay(for: Date(timeIntervalSince1970: Double(ticket.dateMillis) / 1000))
        }
        return grouped.map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
                      .sorted { $0.date < $1.date }
    }

    private var categoryTotals: [(name: String, total: Double)] {
        let grouped = Dictionary(grouping: storeTickets) { $0.category }
        return grouped.map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
                      .sorted { $0.total > $1.total }
                      .prefix(3)
                      .map { $0 }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    heroSection
                    statsGrid
                    if let info = lastPurchaseInfo {
                        lastPurchaseCard(info)
                    }
                    if thisMonthTotal > 0 || lastMonthTotal > 0 {
                        monthComparisonCard
                    }
                    if !groupedByDay.isEmpty {
                        chartSection
                    }
                    if !categoryTotals.isEmpty {
                        topCategoriesSection
                    }
                    ticketListSection
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 48)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(storeName.uppercased())
                .font(.caption)
                .tracking(1.5)
                .foregroundColor(.secondary)
            Text(String(format: "%.2f €", totalAmount))
                .font(.system(size: 56, weight: .heavy, design: .rounded))
                .kerning(-1.5)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.primaryBlue, Theme.primaryBlue.opacity(0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text("\(ticketCount) ticket(s) enregistré(s)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Stats Grid

    private var statsGrid: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                statCard(label: "PANIER MOYEN", value: String(format: "%.2f €", averageBasket))
                statCard(label: "TICKETS", value: "\(ticketCount)")
            }
            HStack(spacing: 16) {
                statCard(label: "DERNIÈRE VISITE", value: lastVisitLabel)
                if let freq = avgDaysBetweenVisits {
                    statCard(label: "FRÉQUENCE", value: "/ \(freq) jours")
                } else {
                    statCard(label: "FRÉQUENCE", value: "—")
                }
            }
        }
    }

    private func statCard(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .tracking(1)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    // MARK: - Last Purchase

    private func lastPurchaseCard(_ info: (date: String, amount: Double, category: String)) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DERNIER ACHAT")
                .font(.caption2)
                .tracking(1)
                .foregroundColor(.secondary)
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(info.date)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.primary)
                    Text(info.category)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(String(format: "%.2f €", info.amount))
                    .font(.title3.weight(.heavy))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Theme.primaryBlue, Theme.primaryBlue.opacity(0.75)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }

    // MARK: - Month Comparison

    private var monthComparisonCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("COMPARAISON MENSUELLE")
                .font(.caption2)
                .tracking(1)
                .foregroundColor(.secondary)

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("CE MOIS")
                        .font(.caption2)
                        .tracking(0.8)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f €", thisMonthTotal))
                        .font(.title3.weight(.semibold))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider().frame(height: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text("MOIS DERNIER")
                        .font(.caption2)
                        .tracking(0.8)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.2f €", lastMonthTotal))
                        .font(.title3.weight(.semibold))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 20)

                if lastMonthTotal > 0 {
                    Text(String(format: "%+.1f%%", variationPercent))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(variationPercent >= 0 ? .red : .green)
                        .padding(.leading, 12)
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }

    // MARK: - Chart

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("HISTORIQUE DES ACHATS")
                .font(.caption2)
                .tracking(1)
                .foregroundColor(.secondary)
            StoreBarChartView(data: groupedByDay)
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }

    // MARK: - Top Categories

    private var topCategoriesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TOP CATÉGORIES")
                .font(.caption2)
                .tracking(1)
                .foregroundColor(.secondary)

            ForEach(categoryTotals, id: \.name) { cat in
                HStack {
                    Image(systemName: "tag.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(cat.name)
                        .font(.subheadline)
                    Spacer()
                    Text(String(format: "%.2f €", cat.total))
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Theme.primaryBlue)
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }

    // MARK: - Ticket List

    private var ticketListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TICKETS")
                .font(.caption2)
                .tracking(1)
                .foregroundColor(.secondary)

            ForEach(storeTickets, id: \.objectID) { ticket in
                NavigationLink {
                    TicketDetailView(ticket: ticket)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ticket.category)
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(.primary)
                            Text(DateUtils.shortString(fromMillis: ticket.dateMillis))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Text(String(format: "%.2f €", ticket.amount))
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(Theme.primaryBlue)
                    }
                    .padding(.vertical, 12)
                }
                .buttonStyle(.plain)

                if ticket.objectID != storeTickets.last?.objectID {
                    Divider()
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }
}
