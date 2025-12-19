import SwiftUI
import CoreData

struct TicketHistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest()) private var tickets: FetchedResults<Ticket>

    // 🔍 Recherche & filtres
    @State private var searchText: String = ""
    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var showFilterSheet: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                if filteredTickets.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        Text(emptyStateText)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                } else {
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
            }
            .navigationTitle("Historique")
            .toolbar {
                // Bouton Edit
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }

                // Filtre + Export
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            Haptic.light()     // ✅ corrigé
                            showFilterSheet = true
                        } label: {
                            Image(systemName: hasActiveFilters ?
                                  "line.3.horizontal.decrease.circle.fill" :
                                  "line.3.horizontal.decrease.circle")
                        }

                        TicketExportButton()
                    }
                }
            }
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

    // MARK: - ROW UI
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

    // MARK: - Filtrage intelligent
    private var filteredTickets: [Ticket] {
        var result = Array(tickets)

        // 🔍 Recherche texte
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            let lower = trimmed.lowercased()
            result = result.filter { ticket in
                ticket.storeName.lowercased().contains(lower)
                || ticket.category.lowercased().contains(lower)
                || (ticket.ticketDescription?.lowercased().contains(lower) ?? false)
            }
        }

        // 📅 Date min
        if let start = startDate {
            let startMs = Int64(start.timeIntervalSince1970 * 1000)
            result = result.filter { $0.dateMillis >= startMs }
        }

        // 📅 Date max (23:59:59)
        if let end = endDate {
            let endDay = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: end) ?? end
            let endMs = Int64(endDay.timeIntervalSince1970 * 1000)
            result = result.filter { $0.dateMillis <= endMs }
        }

        // Tri descendant
        result.sort { $0.dateMillis > $1.dateMillis }
        return result
    }

    private var hasActiveFilters: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        || startDate != nil
        || endDate != nil
    }

    private var emptyStateText: String {
        if tickets.isEmpty { return "Aucun ticket enregistré" }
        if hasActiveFilters { return "Aucun ticket ne correspond à vos filtres." }
        return "Aucun ticket enregistré"
    }

    // MARK: - Actions
    private func deleteTickets(offsets: IndexSet) {
        offsets
            .map { filteredTickets[$0] }
            .forEach(viewContext.delete)

        try? viewContext.save()
        Haptic.medium()    // 🔥 amélioré
    }

    private func clearFilters() {
        startDate = nil
        endDate = nil
        searchText = ""
    }

    private func dateFromMillis(_ ms: Int64) -> Date {
        Date(timeIntervalSince1970: TimeInterval(ms) / 1000)
    }
}
