import SwiftUI
import CoreData

struct TicketHistoryView: View {

    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    @State private var searchText    = ""
    @State private var showFilter    = false
    @State private var filterStart: Date? = nil
    @State private var filterEnd:   Date? = nil

    // MARK: - Filtering

    private var isFilterActive: Bool {
        filterStart != nil || filterEnd != nil
    }

    private var filteredTickets: [Ticket] {
        let cal = Calendar.current
        return tickets.filter { ticket in
            let matchesSearch = searchText.isEmpty
                || ticket.storeName.localizedCaseInsensitiveContains(searchText)
                || ticket.category.localizedCaseInsensitiveContains(searchText)

            let date = DateUtils.date(fromMillis: ticket.dateMillis)

            let matchesStart = filterStart.map { start in
                ticket.dateMillis >= DateRangeHelper.millis(cal.startOfDay(for: start))
            } ?? true

            let matchesEnd = filterEnd.map { end in
                let dayAfter = cal.date(byAdding: .day, value: 1, to: cal.startOfDay(for: end))!
                return ticket.dateMillis < DateRangeHelper.millis(dayAfter)
            } ?? true

            return matchesSearch && matchesStart && matchesEnd
        }
    }

    // MARK: - Grouping

    private var groupedTickets: [(label: String, tickets: [Ticket])] {
        let cal = Calendar.current
        let now = Date()
        let startOfToday     = cal.startOfDay(for: now)
        let startOfYesterday = cal.date(byAdding: .day, value: -1, to: startOfToday)!
        let startOfWeek      = cal.date(from: cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
        let startOfMonth     = cal.date(from: cal.dateComponents([.year, .month], from: now))!

        var buckets: [(String, [Ticket])] = [
            ("Aujourd'hui",   []),
            ("Hier",          []),
            ("Cette semaine", []),
            ("Ce mois",       []),
            ("Plus ancien",   [])
        ]

        for ticket in filteredTickets {
            let day = cal.startOfDay(for: DateUtils.date(fromMillis: ticket.dateMillis))
            if      day >= startOfToday     { buckets[0].1.append(ticket) }
            else if day >= startOfYesterday { buckets[1].1.append(ticket) }
            else if day >= startOfWeek      { buckets[2].1.append(ticket) }
            else if day >= startOfMonth     { buckets[3].1.append(ticket) }
            else                            { buckets[4].1.append(ticket) }
        }

        return buckets.filter { !$0.1.isEmpty }
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                if filteredTickets.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 32) {
                            ForEach(groupedTickets, id: \.label) { section in
                                VStack(alignment: .leading, spacing: 12) {
                                    Text(section.label.uppercased())
                                        .font(.caption2)
                                        .tracking(1)
                                        .foregroundColor(.secondary)

                                    ForEach(section.tickets, id: \.objectID) { ticket in
                                        NavigationLink {
                                            TicketDetailView(ticket: ticket)
                                        } label: {
                                            ticketCard(ticket)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle("Historique")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showFilter = true
                    } label: {
                        Image(systemName: isFilterActive
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                            .foregroundColor(isFilterActive ? Theme.primaryBlue : .primary)
                    }
                }
            }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Rechercher un magasin ou une catégorie"
            )
            .sheet(isPresented: $showFilter) {
                TicketFilterSheet(
                    startDate: $filterStart,
                    endDate:   $filterEnd,
                    onClear:   {}
                )
            }
        }
    }

    // MARK: - Ticket Card

    private func ticketCard(_ ticket: Ticket) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(ticket.storeName)
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack(spacing: 6) {
                    if !ticket.category.isEmpty {
                        Text(ticket.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("·")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Text(DateUtils.shortString(fromMillis: ticket.dateMillis))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(String(format: "%.2f €", ticket.amount))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.primaryBlue, Theme.primaryBlue.opacity(0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: searchText.isEmpty && !isFilterActive ? "tray" : "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text(searchText.isEmpty && !isFilterActive ? "Aucun ticket" : "Aucun résultat")
                .font(.subheadline)
                .foregroundColor(.secondary)

            if isFilterActive {
                Button("Effacer les filtres") {
                    filterStart = nil
                    filterEnd   = nil
                }
                .font(.caption.weight(.medium))
                .foregroundColor(Theme.primaryBlue)
            }
        }
    }
}
