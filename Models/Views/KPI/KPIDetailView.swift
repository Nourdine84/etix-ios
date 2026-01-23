import SwiftUI
import CoreData

struct KPIDetailView: View {

    let type: KPIType

    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    // MARK: - Filtrage selon le KPI
    private var filteredTickets: [Ticket] {
        let now = Date()
        let calendar = Calendar.current

        switch type {
        case .today:
            let start = calendar.startOfDay(for: now)
            let startMs = Int64(start.timeIntervalSince1970 * 1000)
            return tickets.filter { $0.dateMillis >= startMs }

        case .month:
            let comps = calendar.dateComponents([.year, .month], from: now)
            let start = calendar.date(from: comps) ?? now
            let startMs = Int64(start.timeIntervalSince1970 * 1000)
            return tickets.filter { $0.dateMillis >= startMs }

        case .all:
            return Array(tickets)
        }
    }

    private var total: Double {
        filteredTickets.reduce(0) { $0 + $1.amount }
    }

    private var title: String {
        switch type {
        case .today: return "Aujourd’hui"
        case .month: return "Ce mois"
        case .all: return "Tous les tickets"
        }
    }

    // MARK: - UI
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                header

                if filteredTickets.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 12) {
                        ForEach(filteredTickets.sorted(by: { $0.dateMillis > $1.dateMillis }),
                                id: \.objectID) { ticket in
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
            .padding(.top, 16)
        }
        .navigationTitle(title)
    }

    // MARK: - Components

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(String(format: "%.2f €", total))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(Theme.primaryBlue))

            Text("\(filteredTickets.count) ticket\(filteredTickets.count > 1 ? "s" : "")")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        .padding(.horizontal)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            Text("Aucun ticket")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    private func ticketRow(_ t: Ticket) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(t.storeName)
                    .font(.headline)
                Spacer()
                Text(String(format: "%.2f €", t.amount))
                    .foregroundColor(Color(Theme.primaryBlue))
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
}
