import SwiftUI
import CoreData

struct KPIDetailView: View {

    let type: KPIType

    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    // MARK: - Filtrage KPI

    private var filteredTickets: [Ticket] {
        let now = Date()
        let calendar = Calendar.current

        let result: [Ticket]

        switch type {
        case .today:
            let start = calendar.startOfDay(for: now)
            let startMs = Int64(start.timeIntervalSince1970 * 1000)
            result = tickets.filter { $0.dateMillis >= startMs }

        case .month:
            let comps = calendar.dateComponents([.year, .month], from: now)
            let start = calendar.date(from: comps) ?? now
            let startMs = Int64(start.timeIntervalSince1970 * 1000)
            result = tickets.filter { $0.dateMillis >= startMs }

        case .all:
            result = Array(tickets)
        }

        // Tri par date décroissante (UX)
        return result.sorted { $0.dateMillis > $1.dateMillis }
    }

    private var total: Double {
        filteredTickets.reduce(0) { $0 + $1.amount }
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // ✅ Header KPI réutilisable
                KPIHeaderView(
                    title: type.title,
                    total: total,
                    ticketCount: filteredTickets.count
                )
                .padding(.top, 8)

                if filteredTickets.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 12) {
                        ForEach(filteredTickets, id: \.objectID) { ticket in
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
            .padding(.bottom, 16)
        }
        .navigationTitle(type.title)
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
