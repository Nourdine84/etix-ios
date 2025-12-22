import SwiftUI
import CoreData

struct TicketHistoryView: View {

    // MARK: - Core Data
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    // MARK: - UI State
    @State private var searchText = ""
    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var showFilterSheet = false

    var body: some View {
        NavigationView {
            ZStack {
                if filteredTickets.isEmpty {
                    emptyState
                } else {
                    ticketList
                }
            }
            .navigationTitle("Historique")
            .toolbar { historyToolbar }
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .automatic),
                prompt: "Rechercher un ticket"
            )
            .sheet(isPresented: $showFilterSheet) {
                TicketFilterSheet(
                    startDate: $startDate,
                    endDate: $endDate,
                    onClear: clearFilters
                )
            }
        }
    }
}

// MARK: - Subviews
private extension TicketHistoryView {

    var ticketList: some View {
        List {
            ForEach(filteredTickets, id: \.objectID) { ticket in
                NavigationLink(destination: TicketDetailView(ticket: ticket)) {
                    ticketRow(ticket)
                }
                .listRowSeparator(.hidden)
            }
            .onDelete(perform: deleteTickets)
        }
        .listStyle(.plain)
    }

    var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(.gray)

            Text(emptyStateText)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }

    func ticketRow(_ ticket: Ticket) -> some View {
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

            if let desc = ticket.ticketDescription, !desc.isEmpty {
                Text(desc)
                    .font(.body)
            }

            Text(dateFromMillis(ticket.dateMillis), style: .date)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 3, y: 2)
    }
}
// MARK: - Toolbar & Logic
private extension TicketHistoryView {

    var historyToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 16) {
                    Button {
                        Haptic.light()
                        showFilterSheet = true
                    } label: {
                        Image(systemName: hasActiveFilters
                              ? "line.3.horizontal.decrease.circle.fill"
                              : "line.3.horizontal.decrease.circle")
                    }

                    TicketExportButton()
                }
            }
        }
    }

    var filteredTickets: [Ticket] {
        var result = Array(tickets)

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            let lower = query.lowercased()
            result = result.filter {
                $0.storeName.lowercased().contains(lower)
                || $0.category.lowercased().contains(lower)
                || ($0.ticketDescription?.lowercased().contains(lower) ?? false)
            }
        }

        if let start = startDate {
            let startMs = Int64(start.timeIntervalSince1970 * 1000)
            result = result.filter { $0.dateMillis >= startMs }
        }

        if let end = endDate {
            let endDay = Calendar.current.date(
                bySettingHour: 23, minute: 59, second: 59, of: end
            ) ?? end
            let endMs = Int64(endDay.timeIntervalSince1970 * 1000)
            result = result.filter { $0.dateMillis <= endMs }
        }

        return result.sorted { $0.dateMillis > $1.dateMillis }
    }

    var hasActiveFilters: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || startDate != nil
        || endDate != nil
    }

    var emptyStateText: String {
        if tickets.isEmpty { return "Aucun ticket enregistré" }
        if hasActiveFilters { return "Aucun ticket ne correspond à vos filtres." }
        return "Aucun ticket enregistré"
    }

    func deleteTickets(offsets: IndexSet) {
        offsets
            .map { filteredTickets[$0] }
            .forEach(viewContext.delete)

        try? viewContext.save()
        Haptic.medium()
    }

    func clearFilters() {
        startDate = nil
        endDate = nil
        searchText = ""
    }

    func dateFromMillis(_ ms: Int64) -> Date {
        Date(timeIntervalSince1970: TimeInterval(ms) / 1000)
    }
}
