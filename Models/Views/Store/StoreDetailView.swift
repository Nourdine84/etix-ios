import SwiftUI
import CoreData

struct StoreDetailView: View {

    let storeName: String

    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    private var storeTickets: [Ticket] {
        tickets.filter { $0.storeName == storeName }
    }

    private var totalAmount: Double {
        storeTickets.reduce(0) { $0 + $1.amount }
    }

    private var averageAmount: Double {
        guard !storeTickets.isEmpty else { return 0 }
        return totalAmount / Double(storeTickets.count)
    }

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

    var body: some View {
        NavigationStack {
            ZStack {

                DesignSystem.pageBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 32) {

                        header

                        if groupedByDay.isEmpty {
                            emptyState
                        } else {
                            LazyVStack(spacing: 22) {
                                ForEach(groupedByDay, id: \.date) { section in
                                    sectionView(section)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.horizontalPadding)
                    .padding(.vertical, 30)
                }
            }
            .navigationTitle(storeName)
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(storeName)
                .font(.title2.weight(.bold))

            Text(String(format: "%.2f €", totalAmount))
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(Theme.primaryBlue)

            HStack(spacing: 24) {

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
        .premiumCard()
    }

    // MARK: - Section View

    private func sectionView(_ section: (date: Date, items: [Ticket])) -> some View {
        VStack(alignment: .leading, spacing: 14) {

            Text(sectionTitle(section.date))
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)

            VStack(spacing: 14) {
                ForEach(section.items, id: \.objectID) { ticket in
                    ticketRow(ticket)
                }
            }
        }
    }

    // MARK: - Ticket Row

    private func ticketRow(_ ticket: Ticket) -> some View {
        VStack(alignment: .leading, spacing: 8) {
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
        .premiumCard()
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
        VStack(spacing: 18) {
            Image(systemName: "building.2")
                .font(.system(size: 44))
                .foregroundColor(.gray)

            Text("Aucun ticket pour ce magasin")
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 80)
    }
}
