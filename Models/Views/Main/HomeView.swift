import SwiftUI
import CoreData

struct HomeView: View {

    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    @State private var range: TimeRange = .month

    private var filteredTickets: [Ticket] {
        let r = DateRangeHelper.currentRange(for: range)
        let startMs = DateRangeHelper.millis(r.start)
        let endMs = DateRangeHelper.millis(r.end)

        return tickets.filter {
            $0.dateMillis >= startMs && $0.dateMillis < endMs
        }
    }

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

    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.premiumBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: DesignSystem.verticalSpacing) {

                        headerSection
                            .premiumAppear()

                        rangeSelector
                            .premiumAppear()

                        kpiSection
                            .premiumAppear()

                        quickActions
                            .premiumAppear()
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Bienvenue 👋")
                .font(.headline)
                .foregroundColor(.secondary)

            Text("Vos finances en un coup d'œil")
                .font(.title3.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, DesignSystem.horizontalPadding)
    }

    private var rangeSelector: some View {
        Picker("Période", selection: $range) {
            ForEach(TimeRange.allCases) { r in
                Text(r.title).tag(r)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, DesignSystem.horizontalPadding)
    }

    private var kpiSection: some View {
        VStack(spacing: DesignSystem.innerSpacing) {

            VStack(alignment: .leading, spacing: 12) {

                Text("Dépenses")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(String(format: "%.2f €", totalAmount))
                    .font(.system(size: 36, weight: .bold))

                Text("\(ticketCount) ticket(s)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .premiumCard()

            HStack(spacing: DesignSystem.innerSpacing) {

                smallCard(title: "Tickets",
                          value: "\(ticketCount)")

                smallCard(title: "Moyenne",
                          value: String(format: "%.2f €", averageAmount))
            }
        }
        .padding(.horizontal, DesignSystem.horizontalPadding)
    }

    private func smallCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title2.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .premiumCard()
    }

    private var quickActions: some View {
        HStack(spacing: DesignSystem.innerSpacing) {

            quickAction(icon: "plus.circle.fill",
                        title: "Ajouter")

            quickAction(icon: "clock.fill",
                        title: "Historique")
        }
        .padding(.horizontal, DesignSystem.horizontalPadding)
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
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.largeRadius)
                .fill(DesignSystem.cardBackground)
                .shadow(color: DesignSystem.shadowColor,
                        radius: DesignSystem.shadowRadius,
                        x: 0,
                        y: DesignSystem.shadowYOffset)
        )
    }
}
