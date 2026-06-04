import SwiftUI
import CoreData

struct HomeView: View {

    @Environment(\.managedObjectContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    @State private var range: TimeRange = .month

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

    private var ticketCount: Int {
        filteredTickets.count
    }

    private var averageAmount: Double {
        guard ticketCount > 0 else { return 0 }
        return totalAmount / Double(ticketCount)
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {

                DesignSystem.premiumBackground(for: colorScheme)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignSystem.verticalSpacing) {

                        heroSection
                        rangeSelector
                        kpiSection
                        quickActions
                    }
                    .padding(.horizontal, DesignSystem.horizontalPadding)
                    .padding(.vertical, 40)
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Hero Section

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bienvenue")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Vos finances en un coup d'œil")
                .font(.system(size: 24, weight: .bold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Range Selector

    private var rangeSelector: some View {
        Picker("Période", selection: $range) {
            ForEach(TimeRange.allCases) { r in
                Text(r.title).tag(r)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - HERO KPI PREMIUM

    private var kpiSection: some View {

        VStack(spacing: 28) {

            VStack(alignment: .leading, spacing: 14) {

                Text("DÉPENSES")
                    .font(.caption)
                    .textCase(.uppercase)
                    .tracking(1.2)
                    .foregroundColor(.secondary)

                AnimatedAmountText(value: totalAmount)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .kerning(-0.8)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Theme.primaryBlue,
                                Theme.primaryBlue.opacity(0.75)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("\(ticketCount) ticket(s)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(32)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 32)
                        .fill(DesignSystem.surfacePrimary)

                    RoundedRectangle(cornerRadius: 32)
                        .stroke(
                            Theme.primaryBlue.opacity(0.12),
                            lineWidth: 1
                        )
                }
            )
            .shadow(
                color: DesignSystem.shadowColor(for: colorScheme),
                radius: 20,
                x: 0,
                y: 14
            )

            HStack(spacing: 20) {
                smallKPI(title: "Tickets", value: "\(ticketCount)")
                smallKPI(title: "Moyenne", value: String(format: "%.2f €", averageAmount))
            }
        }
    }

    private func smallKPI(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {

            Text(title.uppercased())
                .font(.caption2)
                .tracking(1)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title2.weight(.semibold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.mediumRadius)
                .fill(DesignSystem.surfaceSecondary)
                .shadow(
                    color: DesignSystem.shadowColor(for: colorScheme),
                    radius: DesignSystem.shadowRadius * 0.5,
                    x: 0,
                    y: DesignSystem.shadowYOffset * 0.5
                )
        )
    }

    // MARK: - Quick Actions

    private var quickActions: some View {
        HStack(spacing: 20) {
            quickAction(icon: "plus.circle.fill", title: "Ajouter")
            quickAction(icon: "clock.fill", title: "Historique")
        }
    }

    private func quickAction(icon: String, title: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(Theme.primaryBlue)

            Text(title)
                .font(.footnote.weight(.medium))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 26)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.largeRadius)
                .fill(DesignSystem.surfaceSecondary)
                .shadow(
                    color: DesignSystem.shadowColor(for: colorScheme),
                    radius: DesignSystem.shadowRadius * 0.5,
                    x: 0,
                    y: DesignSystem.shadowYOffset * 0.5
                )
        )
    }
}
