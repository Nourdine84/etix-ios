import SwiftUI
import CoreData

struct TicketHistoryView: View {

    // MARK: - CoreData
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    // MARK: - State
    @State private var searchText = ""
    @State private var showFilterSheet = false

    // MARK: - Filtrage
    private var filteredTickets: [Ticket] {
        guard !searchText.isEmpty else {
            return Array(tickets)
        }

        return tickets.filter {
            $0.storeName.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            List {
                if filteredTickets.isEmpty {
                    emptyState
                } else {
                    ForEach(filteredTickets, id: \.objectID) { ticket in
                        NavigationLink {
                            TicketDetailView(ticket: ticket)
                        } label: {
                            ticketRow(ticket)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Historique")
            .toolbar {

                // 🔍 Filtres
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilterSheet = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }

                // ❌ Export supprimé volontairement
                // 👉 L’export se fait uniquement depuis les écrans KPI
            }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Rechercher un ticket"
            )
        }
    }

    // MARK: - Row
    private func ticketRow(_ ticket: Ticket) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(ticket.storeName)
                    .font(.headline)

                Spacer()

                Text(String(format: "%.2f €", ticket.amount))
                    .bold()
                    .foregroundColor(Color(Theme.primaryBlue))
            }

            Text(ticket.category)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(DateUtils.shortString(fromMillis: ticket.dateMillis))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 6)
    }

    // MARK: - Empty
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
}
