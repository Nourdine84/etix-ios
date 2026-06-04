import SwiftUI
import CoreData

struct TicketHistoryView: View {

    @Environment(\.managedObjectContext) private var context
    @Environment(\.colorScheme) private var colorScheme
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    @State private var searchText = ""

    private var filteredTickets: [Ticket] {
        guard !searchText.isEmpty else { return Array(tickets) }

        return tickets.filter {
            $0.storeName.localizedCaseInsensitiveContains(searchText) ||
            $0.category.localizedCaseInsensitiveContains(searchText)
        }
    }

    private var totalAmount: Double {
        filteredTickets.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            ZStack {

                DesignSystem.premiumBackground(for: colorScheme)
                    .ignoresSafeArea()

                if filteredTickets.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: DesignSystem.verticalSpacing) {

                            headerSection
                                .premiumAppear()

                            LazyVStack(spacing: 14) {
                                ForEach(filteredTickets, id: \.objectID) { ticket in
                                    NavigationLink {
                                        TicketDetailView(ticket: ticket)
                                    } label: {
                                        ticketRow(ticket)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, DesignSystem.horizontalPadding)
                        .padding(.vertical, 40)
                    }
                }
            }
            .navigationTitle("Historique")
            .navigationBarTitleDisplayMode(.large)
            .animation(.easeInOut(duration: 0.25), value: colorScheme)
            .searchable(text: $searchText)
        }
    }

    private var headerSection: some View {

        VStack(alignment: .leading, spacing: 10) {

            Text("TOTAL AFFICHÉ")
                .font(.caption)
                .textCase(.uppercase)
                .tracking(1)
                .foregroundColor(.secondary)

            AnimatedAmountText(value: totalAmount)
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .kerning(-0.5)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.primaryBlue, Theme.primaryBlue.opacity(0.85)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("\(filteredTickets.count) ticket(s)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.largeRadius)
                .fill(DesignSystem.surfacePrimary)
                .shadow(
                    color: DesignSystem.shadowColor(for: colorScheme),
                    radius: DesignSystem.shadowRadius,
                    x: 0,
                    y: DesignSystem.shadowYOffset
                )
        )
    }

    private func ticketRow(_ ticket: Ticket) -> some View {

        VStack(alignment: .leading, spacing: 6) {

            HStack {
                Text(ticket.storeName)
                    .font(.headline)

                Spacer()

                Text(String(format: "%.2f €", ticket.amount))
                    .font(.headline)
                    .foregroundColor(.primary) // calm accent
            }

            Text(ticket.category)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(DateUtils.shortString(fromMillis: ticket.dateMillis))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(20)
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

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray")
                .font(.system(size: 44))
                .foregroundColor(.gray)

            Text("Aucun ticket")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 120)
    }
}
