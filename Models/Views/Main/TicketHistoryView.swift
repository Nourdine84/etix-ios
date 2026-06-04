import SwiftUI
import CoreData

struct TicketHistoryView: View {

    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    @State private var searchText = ""

    private var filteredTickets: [Ticket] {
        guard !searchText.isEmpty else {
            return Array(tickets)
        }

        return tickets.filter {
            $0.storeName.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {

                DesignSystem.premiumBackground
                    .ignoresSafeArea()

                if filteredTickets.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.innerSpacing) {

                            ForEach(filteredTickets, id: \.objectID) { ticket in
                                NavigationLink {
                                    TicketDetailView(ticket: ticket)
                                } label: {
                                    ticketRow(ticket)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, DesignSystem.horizontalPadding)
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("Historique")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemBackground), for: .navigationBar)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Rechercher un ticket"
            )
        }
    }

    // MARK: - Row

    private func ticketRow(_ ticket: Ticket) -> some View {

        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text(ticket.storeName)
                    .font(.headline)

                Spacer()

                Text(String(format: "%.2f €", ticket.amount))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.primaryBlue)
            }

            Text(ticket.category)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(DateUtils.shortString(fromMillis: ticket.dateMillis))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .premiumCard()
    }

    // MARK: - Empty

    private var emptyState: some View {

        VStack(spacing: 16) {

            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundColor(.gray)

            Text("Aucun ticket")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
}
