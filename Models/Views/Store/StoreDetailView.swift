import SwiftUI
import CoreData

struct StoreDetailView: View {

    let storeName: String

    @Environment(\.managedObjectContext) private var context
    @FetchRequest private var tickets: FetchedResults<Ticket>

    @State private var showAllTickets = false

    init(storeName: String) {
        self.storeName = storeName
        let request = NSFetchRequest<Ticket>(entityName: "Ticket")
        request.predicate = NSPredicate(format: "storeName == %@", storeName)
        request.sortDescriptors = [NSSortDescriptor(key: "dateMillis", ascending: false)]
        _tickets = FetchRequest(fetchRequest: request)
    }

    // MARK: - Static Formatters

    private static let mediumFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    private static let longFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.dateStyle = .long
        f.timeStyle = .none
        return f
    }()

    // MARK: - Computed

    private var totalAmount: Double {
        tickets.reduce(0) { $0 + $1.amount }
    }

    private var ticketCount: Int { tickets.count }

    private var averageBasket: Double {
        guard ticketCount > 0 else { return 0 }
        return totalAmount / Double(ticketCount)
    }

    private var thisMonthTotal: Double {
        let r = DateRangeHelper.currentRange(for: .month)
        let startMs = DateRangeHelper.millis(r.start)
        let endMs = DateRangeHelper.millis(r.end)
        return tickets
            .filter { $0.dateMillis >= startMs && $0.dateMillis < endMs }
            .reduce(0) { $0 + $1.amount }
    }

    private var lastMonthTotal: Double {
        let r = DateRangeHelper.previousRange(for: .month)
        let startMs = DateRangeHelper.millis(r.start)
        let endMs = DateRangeHelper.millis(r.end)
        return tickets
            .filter { $0.dateMillis >= startMs && $0.dateMillis < endMs }
            .reduce(0) { $0 + $1.amount }
    }

    private var variationPercent: Double {
        guard lastMonthTotal > 0 else { return 0 }
        return ((thisMonthTotal - lastMonthTotal) / lastMonthTotal) * 100
    }

    private var lastVisitLabel: String {
        guard let first = tickets.first else { return "—" }
        return Self.mediumFormatter.string(
            from: Date(timeIntervalSince1970: Double(first.dateMillis) / 1000)
        )
    }

    private var avgDaysBetweenVisits: Int? {
        guard tickets.count >= 2,
              let newest = tickets.first?.dateMillis,
              let oldest = tickets.last?.dateMillis else { return nil }
        let spanDays = Int((Double(newest - oldest) / 1000 / 86400).rounded())
        return max(1, spanDays / (tickets.count - 1))
    }

    private var groupedByDay: [(date: Date, total: Double)] {
        let cal = Calendar.current
        let grouped = Dictionary(grouping: tickets) { ticket in
            cal.startOfDay(for: Date(timeIntervalSince1970: Double(ticket.dateMillis) / 1000))
        }
        return grouped
            .map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .sorted { $0.0 < $1.0 }
    }

    private var categoryBreakdown: [(name: String, total: Double, percent: Double)] {
        let grouped = Dictionary(grouping: tickets) { $0.category }
        let pairs: [(String, Double)] = grouped.map { key, values in
            (key.isEmpty ? "Autre" : key, values.reduce(0) { $0 + $1.amount })
        }
        let grandTotal = pairs.reduce(0) { $0 + $1.1 }
        return Array(
            pairs
                .map { (name: $0.0, total: $0.1, percent: grandTotal > 0 ? $0.1 / grandTotal * 100 : 0) }
                .sorted { $0.total > $1.total }
                .prefix(3)
        )
    }

    private var displayedTickets: [Ticket] {
        showAllTickets ? Array(tickets) : Array(tickets.prefix(5))
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    heroSection
                    statsGrid
                    if thisMonthTotal > 0 || lastMonthTotal > 0 {
                        monthComparisonCard
                    }
                    if !groupedByDay.isEmpty {
                        chartSection
                    }
                    if !categoryBreakdown.isEmpty {
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
            Text("\(ticketCount) ticket\(ticketCount > 1 ? "s" : "") enregistré\(ticketCount > 1 ? "s" : "")")
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
                statCard(
                    label: "FRÉQUENCE",
                    value: avgDaysBetweenVisits.map { "tous les \($0) j" } ?? "—"
                )
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

            ForEach(categoryBreakdown, id: \.name) { cat in
                HStack(spacing: 8) {
                    Text(cat.name)
                        .font(.caption)
                        .lineLimit(1)
                        .frame(width: 90, alignment: .leading)
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(.systemFill))
                            .frame(height: 4)
                        Capsule()
                            .fill(Theme.primaryBlue.opacity(0.7))
                            .scaleEffect(x: min(cat.percent / 100, 1.0), anchor: .leading)
                            .frame(height: 4)
                    }
                    Text(String(format: "%.0f%%", cat.percent))
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.secondary)
                        .frame(width: 30, alignment: .trailing)
                    Text(String(format: "%.0f €", cat.total))
                        .font(.caption2.weight(.semibold))
                        .frame(width: 52, alignment: .trailing)
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
            Text("TICKETS (\(ticketCount))")
                .font(.caption2)
                .tracking(1)
                .foregroundColor(.secondary)

            ForEach(Array(displayedTickets.enumerated()), id: \.element.objectID) { index, ticket in
                NavigationLink {
                    TicketDetailView(ticket: ticket)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(ticket.category.isEmpty ? "Sans catégorie" : ticket.category)
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

                if index < displayedTickets.count - 1 {
                    Divider()
                }
            }

            if ticketCount > 5 && !showAllTickets {
                Divider()
                Button {
                    withAnimation { showAllTickets = true }
                } label: {
                    Text("Voir les \(ticketCount - 5) autres tickets →")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(Theme.primaryBlue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }
}
