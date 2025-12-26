import SwiftUI
import CoreData

struct TicketHistoryView: View {

    // MARK: - Core Data
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    // MARK: - UI State
    @State private var searchText: String = ""
    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var showFilterSheet: Bool = false

    var body: some View {
        NavigationView {
            ZStack {
                if filteredTickets.isEmpty {
                    emptyState
                        .transition(.opacity)
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
        .onTapGesture {
            hideKeyboard()
        }
    }
}

// MARK: - Subviews
private extension TicketHistoryView {

    var ticketList: some View {
        List {
            ForEach(filteredTickets, id: \.objectID) { ticket in
                NavigationLink {
                    TicketDetailView(ticket: ticket)
                } label: {
                    ticketRow(ticket)
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .onDelete(perform: deleteTickets)
        }
        .listStyle(.plain)
        .scrollDismissesKeyboard(.immediately)
    }

    var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 42))
                .foregroundColor(Color(Theme.primaryBlue))

            Text(emptyStateText)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 80)
    }

    func ticketRow(_ ticket: Ticket) -> some View {
        VStack(alignment: .leading, spacing: 8) {

            // Ligne principale
            HStack(alignment: .top) {
                Text(ticket.storeName)
                    .font(.headline)

                Spacer()

                Text(String(format: "%.2f €", ticket.amount))
                    .font(.headline)
                    .foregroundColor(Color(Theme.primaryBlue))
            }

            // Catégorie
            Text(ticket.category)
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Description optionnelle
            if let desc = ticket.ticketDescription, !desc.isEmpty {
                Text(desc)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

            // Date
            Text(dateFromMillis(ticket.dateMillis), style: .date)
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        .contentShape(Rectangle()) // 👈 zone cliquable confortable
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

        // 🔍 Recherche texte
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !query.isEmpty {
            result = result.filter {
                $0.storeName.lowercased().contains(query)
                || $0.category.lowercased().contains(query)
                || ($0.ticketDescription?.lowercased().contains(query) ?? false)
            }
        }

        // 📅 Date min
        if let start = startDate {
            let startMs = Int64(start.timeIntervalSince1970 * 1000)
            result = result.filter { $0.dateMillis >= startMs }
        }

        // 📅 Date max
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
        if tickets.isEmpty {
            return "Aucun ticket enregistré"
        }
        if hasActiveFilters {
            return "Aucun ticket ne correspond à vos filtres."
        }
        return "Aucun ticket enregistré"
    }

    func deleteTickets(offsets: IndexSet) {
        offsets
            .map { filteredTickets[$0] }
            .forEach(viewContext.delete)

        do {
            try viewContext.save()
            Haptic.medium()
        } catch {
            print("❌ Delete error:", error.localizedDescription)
            Haptic.error()
        }
    }

    func clearFilters() {
        startDate = nil
        endDate = nil
        searchText = ""
    }

    func dateFromMillis(_ ms: Int64) -> Date {
        Date(timeIntervalSince1970: TimeInterval(ms) / 1000)
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
