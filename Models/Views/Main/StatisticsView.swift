import SwiftUI
import CoreData

struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    // MARK: - Data du mois en cours
    private var monthTickets: [Ticket] {
        let now = Date()
        let comps = Calendar.current.dateComponents([.year, .month], from: now)
        let startMonth = Calendar.current.date(from: comps) ?? now
        let startMs = Int64(startMonth.timeIntervalSince1970 * 1000)

        return tickets.filter { $0.dateMillis >= startMs }
    }

    private var monthTotal: Double {
        monthTickets.reduce(0) { $0 + $1.amount }
    }

    private var monthCount: Int {
        monthTickets.count
    }

    private var averageAmount: Double {
        monthCount == 0 ? 0 : monthTotal / Double(monthCount)
    }

    private var highestTicket: Ticket? {
        monthTickets.max(by: { $0.amount < $1.amount })
    }

    private var topCategory: CategorySummary? {
        let grouped = Dictionary(grouping: monthTickets) { $0.category }
        let mapped = grouped.map { (cat, items) in
            CategorySummary(name: cat.isEmpty ? "Autre" : cat,
                            total: items.reduce(0) { $0 + $1.amount },
                            count: items.count,
                            percent: 0)
        }
        return mapped.sorted(by: { $0.total > $1.total }).first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 22) {

                    // 🔵 Carte "Résumé du mois"
                    summaryCard

                    if monthTickets.isEmpty {
                        emptyState
                    } else {

                        // 🟣 Statistiques détaillées
                        VStack(spacing: 16) {
                            statRow(title: "Total du mois", value: String(format: "%.2f €", monthTotal))
                            statRow(title: "Nombre de tickets", value: "\(monthCount)")
                            statRow(title: "Dépense moyenne", value: String(format: "%.2f €", averageAmount))

                            if let high = highestTicket {
                                statRow(title: "Plus grosse dépense",
                                        value: String(format: "%.2f € — %@", high.amount, high.storeName))
                            }

                            if let cat = topCategory {
                                statRow(title: "Catégorie la plus utilisée",
                                        value: "\(cat.name) (\(cat.count)×)")
                            }
                        }
                        .padding(.horizontal)

                        // 🟦 Liste des tickets du mois (mode compact)
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tickets du mois")
                                .font(.title3.bold())
                                .padding(.horizontal)

                            ForEach(monthTickets.sorted(by: { $0.dateMillis > $1.dateMillis }),
                                    id: \.objectID) { t in
                                NavigationLink {
                                    TicketDetailView(ticket: t)
                                } label: {
                                    ticketRow(t)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.top, 16)
            }
            .navigationTitle("Statistiques")
        }
    }

    // MARK: - Carte Résumé

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 10) {

            Text("Résumé du mois")
                .font(.headline)

            Text(String(format: "%.2f €", monthTotal))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(Color(Theme.primaryBlue))

            Text("\(monthCount) ticket\(monthCount > 1 ? "s" : "")")
                .font(.subheadline)
                .foregroundColor(.secondary)

        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.system(size: 42))
                .foregroundColor(.gray)

            Text("Aucune donnée pour ce mois.")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: - Rows

    private func statRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(value)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
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
        .shadow(color: .black.opacity(0.06), radius: 3, y: 2)
        .padding(.horizontal)
    }
}


// MARK: - Summary Struct

private struct CategorySummary: Identifiable {
    let id = UUID()
    let name: String
    let total: Double
    let count: Int
    let percent: Double
}
