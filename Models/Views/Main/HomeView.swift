import SwiftUI
import CoreData

struct HomeView: View {

    // MARK: - CoreData
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    // MARK: - State
    @State private var range: TimeRange = .month

    // MARK: - Tickets filtrés
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
            ScrollView {
                VStack(spacing: 24) {

                    // 🔁 RANGE SELECTOR
                    rangeSelector

                    // 🔵 KPI CARDS
                    kpiSection

                    // ⚡ Accès rapides
                    quickActions
                }
                .padding(.vertical)
            }
            .navigationTitle("Accueil")
        }
    }

    // MARK: - Range Selector
    private var rangeSelector: some View {
        Picker("Période", selection: $range) {
            ForEach(TimeRange.allCases) { r in
                Text(r.title).tag(r)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }

    // MARK: - KPI Section
    private var kpiSection: some View {
        VStack(spacing: 16) {

            // 💰 TOTAL DÉPENSES
            NavigationLink {
                KPIDetailView(
                    type: .month,
                    range: range
                )
            } label: {
                KPIPrimaryCard(
                    title: "Dépenses",
                    value: totalAmount,
                    subtitle: "\(ticketCount) ticket(s)",
                    color: Theme.primaryBlue
                )
            }
            .buttonStyle(.plain)

            HStack(spacing: 12) {

                // 🎫 TICKETS
                NavigationLink {
                    KPIDetailView(
                        type: .tickets,
                        range: range
                    )
                } label: {
                    KPISmallCard(
                        title: "Tickets",
                        value: Double(ticketCount),
                        unit: ""
                    )
                }

                // 📈 MOYENNE
                NavigationLink {
                    KPIDetailView(
                        type: .month,
                        range: range
                    )
                } label: {
                    KPISmallCard(
                        title: "Moyenne",
                        value: averageAmount,
                        unit: "€"
                    )
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - Quick Actions
    private var quickActions: some View {
        HStack(spacing: 12) {

            NavigationLink {
                AddTicketView()
            } label: {
                quickAction(
                    icon: "plus.circle.fill",
                    title: "Ajouter"
                )
            }

            NavigationLink {
                TicketHistoryView()
            } label: {
                quickAction(
                    icon: "list.bullet",
                    title: "Historique"
                )
            }
        }
        .padding(.horizontal)
    }

    private func quickAction(icon: String, title: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(Theme.primaryBlue)

            Text(title)
                .font(.caption)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }
}
