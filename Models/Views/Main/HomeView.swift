import SwiftUI
import CoreData

struct HomeView: View {

    @Environment(\.managedObjectContext) private var context
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
                        secondaryKPIs
                        quickActions
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
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
            statCard(title: "Moyenne", value: String(format: "%.2f €", averageAmount))
            statCard(title: "Tickets", value: "\(ticketCount)")
        }
    }

    private func statCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
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
}
