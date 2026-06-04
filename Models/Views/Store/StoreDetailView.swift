import SwiftUI
import CoreData

struct StoreDetailView: View {

    // MARK: - Input
    let storeName: String

    // MARK: - CoreData
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    // MARK: - Store Tickets
    private var storeTickets: [Ticket] {
        tickets.filter { $0.storeName == storeName }
    }

    // MARK: - Totals
    private var totalAmount: Double {
        storeTickets.reduce(0) { $0 + $1.amount }
    }

    private var averageAmount: Double {
        guard !storeTickets.isEmpty else { return 0 }
        return totalAmount / Double(storeTickets.count)
    }

    // MARK: - Grouped by day
    private var groupedByDay: [(date: Date, items: [Ticket])] {
        let calendar = Calendar.current

        let grouped = Dictionary(grouping: storeTickets) { ticket -> Date in
            let date = Date(
                timeIntervalSince1970: TimeInterval(ticket.dateMillis) / 1000
            )
            return calendar.startOfDay(for: date)
        }

        return grouped
            .map { ($0.key, $0.value) }
            .sorted { $0.date > $1.date }
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {

                        header

                        if groupedByDay.isEmpty {
                            emptyState
                        } else {
                            LazyVStack(spacing: 20) {
                                ForEach(groupedByDay, id: \.date) { section in
                                    sectionView(section)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle(storeName)
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text(storeName)
                .font(.title2.bold())

            Text(String(format: "%.2f €", totalAmount))
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(Theme.primaryBlue)

            HStack(spacing: 16) {

                VStack(alignment: .leading) {
                    Text("Tickets")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("\(storeTickets.count)")
                        .font(.headline)
                }

                VStack(alignment: .leading) {
                    Text("Moyenne")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text(String(format: "%.2f €", averageAmount))
                        .font(.headline)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(
            RoundedRectangle(cornerRadius: 26)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        .padding(.horizontal)
    }

    // MARK: - Section View
    private func sectionView(_ section: (date: Date, items: [Ticket])) -> some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(sectionTitle(section.date))
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                ForEach(section.items, id: \.objectID) { ticket in
                    ticketRow(ticket)
                }
            }
        }
    }

    // MARK: - Ticket Row
    private func ticketRow(_ ticket: Ticket) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(ticket.category)
                    .font(.headline)

                Spacer()

                Text(String(format: "%.2f €", ticket.amount))
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.primaryBlue)
            }

            Text(DateUtils.shortString(fromMillis: ticket.dateMillis))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .shadow(color: .black.opacity(0.04), radius: 5, y: 3)
    }

    // MARK: - Date Title
    private func sectionTitle(_ date: Date) -> String {
        let cal = Calendar.current

        if cal.isDateInToday(date) { return "Aujourd’hui" }
        if cal.isDateInYesterday(date) { return "Hier" }

        return DateFormatter.localizedString(
            from: date,
            dateStyle: .medium,
            timeStyle: .none
        )
    }

    // MARK: - Empty
    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "building.2")
                .font(.system(size: 42))
                .foregroundColor(.gray)

            Text("Aucun ticket pour ce magasin")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}
