import SwiftUI
import CoreData

struct HomeView: View {

    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    @State private var range: TimeRange = AppSettings.load().defaultRange
    @State private var budgets: [String: Double] = BudgetStore.load()

    // MARK: - Filtering

    private var filteredTickets: [Ticket] {
        let r = DateRangeHelper.currentRange(for: range)
        let startMs = DateRangeHelper.millis(r.start)
        let endMs = DateRangeHelper.millis(r.end)
        return tickets.filter {
            $0.dateMillis >= startMs && $0.dateMillis < endMs
        }
    }

    // MARK: - KPIs

    private var totalAmount: Double {
        filteredTickets.reduce(0) { $0 + $1.amount }
    }

    private var ticketCount: Int { filteredTickets.count }

    private var averageAmount: Double {
        guard ticketCount > 0 else { return 0 }
        return totalAmount / Double(ticketCount)
    }

    private var previousPeriodTotal: Double {
        let r = DateRangeHelper.previousRange(for: range)
        let startMs = DateRangeHelper.millis(r.start)
        let endMs = DateRangeHelper.millis(r.end)
        return tickets.filter {
            $0.dateMillis >= startMs && $0.dateMillis < endMs
        }.reduce(0) { $0 + $1.amount }
    }

    private var deltaPercent: Double? {
        guard previousPeriodTotal > 0 else { return nil }
        return ((totalAmount - previousPeriodTotal) / previousPeriodTotal) * 100
    }

    private var deltaLabel: String {
        switch range {
        case .today:  return "vs hier"
        case .month:  return "vs mois précédent"
        case .year:   return "vs année précédente"
        }
    }

    // MARK: - Analytics

    private var topCategory: (name: String, total: Double)? {
        guard !filteredTickets.isEmpty else { return nil }
        return Dictionary(grouping: filteredTickets) { $0.category }
            .map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .max { $0.1 < $1.1 }
            .map { (name: $0.0, total: $0.1) }
    }

    private var topStore: (name: String, total: Double)? {
        guard !filteredTickets.isEmpty else { return nil }
        return Dictionary(grouping: filteredTickets) { $0.storeName }
            .map { ($0.key, $0.value.reduce(0) { $0 + $1.amount }) }
            .max { $0.1 < $1.1 }
            .map { (name: $0.0, total: $0.1) }
    }

    private var biggestTicket: Ticket? {
        filteredTickets.max { $0.amount < $1.amount }
    }

    private var lastTicket: Ticket? {
        filteredTickets.max { $0.dateMillis < $1.dateMillis }
    }

    // MARK: - Intelligence

    private var homeSnapshot: HomeSnapshot {
        HomeSnapshot(tickets: Array(tickets), range: range)
    }

    /// Résultat brut du moteur store — consommé par l'insight engine (exclusion
    /// newStore vs newMerchant) puis par la carte, après application du masquage
    private var rawStoreIntelligence: StoreIntelligence? {
        StoreIntelligenceEngine.evaluate(snapshot: homeSnapshot, range: range)
    }

    private var activeInsights: [HomeInsight] {
        HomeInsightEngine.evaluate(
            snapshot: homeSnapshot,
            budgets: budgets,
            range: range,
            storeIntelligence: rawStoreIntelligence
        )
    }

    private var budgetSummary: BudgetSummary? {
        guard range == .month else { return nil }
        return BudgetSummaryEngine.compute(snapshot: homeSnapshot, budgets: budgets)
    }

    private var storeIntelligence: StoreIntelligence? {
        guard activeInsights.first?.id != .budgetExceeded else { return nil }
        return rawStoreIntelligence
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 48) {
                        header
                        dominantHero
                        periodSelector
                        if !activeInsights.isEmpty {
                            insightCardsSection
                        }
                        if let summary = budgetSummary {
                            BudgetSummaryCardView(summary: summary)
                        }
                        if let intel = storeIntelligence {
                            StoreIntelligenceCardView(intelligence: intel)
                        }
                        secondaryKPIs
                        if !filteredTickets.isEmpty {
                            analyticsSection
                        }
                        quickActions
                        if range == .month && !filteredTickets.isEmpty {
                            reportPreviewCard
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                budgets = BudgetStore.load()
            }
        }
    }

    // MARK: - Insight Cards

    private var insightCardsSection: some View {
        VStack(spacing: 12) {
            ForEach(Array(activeInsights.enumerated()), id: \.element.id) { index, insight in
                InsightCardView(insight: insight, isPrimary: index == 0)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("eTix")
                .font(.caption)
                .tracking(2)
                .foregroundColor(.secondary)
            Text("Votre activité financière")
                .font(.system(size: 22, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Dominant Hero

    private var dominantHero: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TOTAL")
                .font(.caption)
                .tracking(1.5)
                .foregroundColor(.secondary)
            AnimatedAmountText(value: totalAmount)
                .font(.system(size: 64, weight: .heavy, design: .rounded))
                .foregroundColor(.primary)
            Text("\(ticketCount) transactions")
                .font(.caption)
                .foregroundColor(.secondary)
            if let delta = deltaPercent {
                HStack(spacing: 4) {
                    Image(systemName: delta >= 0 ? "arrow.up.right" : "arrow.down.right")
                        .font(.caption2.weight(.semibold))
                    Text(String(format: "%+.1f%%", delta))
                        .font(.caption.weight(.semibold))
                    Text(deltaLabel)
                        .font(.caption)
                }
                .foregroundColor(delta >= 0 ? .red : .green)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Period Selector

    private var periodSelector: some View {
        Picker("Période", selection: $range) {
            ForEach(TimeRange.allCases) { r in
                Text(r.title).tag(r)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Secondary KPIs

    private var secondaryKPIs: some View {
        HStack(spacing: 20) {
            statCard(label: "MOYENNE", value: String(format: "%.2f €", averageAmount))
            statCard(label: "TICKETS", value: "\(ticketCount)")
        }
    }

    // MARK: - Analytics

    private var analyticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("INSIGHTS")
                .font(.caption2)
                .tracking(1.5)
                .foregroundColor(.secondary)

            HStack(spacing: 16) {
                analyticsCard(
                    label: "TOP CATÉGORIE",
                    primary: topCategory?.name ?? "—",
                    secondary: topCategory.map { String(format: "%.2f €", $0.total) } ?? ""
                )
                analyticsCard(
                    label: "TOP MAGASIN",
                    primary: topStore?.name ?? "—",
                    secondary: topStore.map { String(format: "%.2f €", $0.total) } ?? ""
                )
            }

            HStack(spacing: 16) {
                analyticsCard(
                    label: "PLUS GROS ACHAT",
                    primary: biggestTicket.map { String(format: "%.2f €", $0.amount) } ?? "—",
                    secondary: biggestTicket?.storeName ?? ""
                )
                analyticsCard(
                    label: "DERNIER ACHAT",
                    primary: lastTicket.map { shortDate($0.dateMillis) } ?? "—",
                    secondary: lastTicket.map { String(format: "%.2f €", $0.amount) } ?? ""
                )
            }
        }
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        HStack(spacing: 20) {
            NavigationLink {
                AddTicketView()
            } label: {
                actionButton(icon: "plus.circle.fill", title: "Ajouter")
            }

            NavigationLink {
                TicketHistoryView()
            } label: {
                actionButton(icon: "clock.fill", title: "Historique")
            }
        }
    }

    // MARK: - Report Preview Card

    private var reportMonthName: String {
        let df = DateFormatter()
        df.locale = Locale(identifier: "fr_FR")
        df.dateFormat = "MMMM"
        return df.string(from: Date()).uppercased()
    }

    private var reportPreviewCard: some View {
        NavigationLink {
            MonthlyReportView()
        } label: {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("RAPPORT DE \(reportMonthName)")
                        .font(.caption2)
                        .tracking(1)
                        .foregroundColor(.secondary)

                    HStack(spacing: 0) {
                        Text(String(format: "%.2f €", totalAmount))
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.primary)
                        Text("  ·  \(ticketCount) ticket\(ticketCount > 1 ? "s" : "")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        if let delta = deltaPercent {
                            Text("  ·  \(String(format: "%+.1f%%", delta))")
                                .font(.subheadline.weight(.medium))
                                .foregroundColor(delta >= 0 ? .red : .green)
                        }
                    }
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(20)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Reusable Components

    private func statCard(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .tracking(1)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2.weight(.semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }

    private func analyticsCard(label: String, primary: String, secondary: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .tracking(1)
                .foregroundColor(.secondary)
            Text(primary)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .truncationMode(.tail)
            if !secondary.isEmpty {
                Text(secondary)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    private func actionButton(icon: String, title: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 26, weight: .semibold))
                .foregroundColor(.primary)
            Text(title)
                .font(.footnote.weight(.medium))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(24)
    }

    // MARK: - Helpers

    private func shortDate(_ ms: Int64) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.dateStyle = .medium
        f.timeStyle = .none
        return f.string(from: Date(timeIntervalSince1970: Double(ms) / 1000))
    }
}
