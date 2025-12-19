import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest()) private var tickets: FetchedResults<Ticket>

    // MARK: - KPI calculés
    private var todayTotal: Double {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let startMs = Int64(startOfDay.timeIntervalSince1970 * 1000)

        return tickets
            .filter { $0.dateMillis >= startMs }
            .map { $0.amount }
            .reduce(0, +)
    }

    private var monthTotal: Double {
        let comps = Calendar.current.dateComponents([.year, .month], from: Date())
        let startOfMonth = Calendar.current.date(from: comps) ?? Date()
        let startMs = Int64(startOfMonth.timeIntervalSince1970 * 1000)

        return tickets
            .filter { $0.dateMillis >= startMs }
            .map { $0.amount }
            .reduce(0, +)
    }

    private var totalTickets: Int {
        tickets.count
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {

                    // MARK: KPI Section
                    kpiSection

                    // MARK: Derniers tickets
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Derniers tickets")
                            .font(.title3.weight(.semibold))
                            .padding(.horizontal)

                        if tickets.isEmpty {
                            emptyState
                        } else {
                            VStack(spacing: 12) {
                                ForEach(tickets.prefix(5), id: \.objectID) { t in
                                    NavigationLink {
                                        TicketDetailView(ticket: t)
                                    } label: {
                                        ticketRow(t)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }

                }
                .padding(.top, 8)
            }
            .navigationTitle("Accueil")
        }
    }

    // MARK: - KPI Section (V1+ Optimisé)
    private var kpiSection: some View {
        HStack(spacing: 14) {

            kpiCard(
                icon: "sun.max.fill",
                title: "Aujourd’hui",
                value: String(format: "%.2f €", todayTotal)
            )

            kpiCard(
                icon: "calendar",
                title: "Ce mois",
                value: String(format: "%.2f €", monthTotal)
            )

            kpiCard(
                icon: "doc.plaintext",
                title: "Tickets",
                value: "\(totalTickets)"
            )
        }
        .padding(.horizontal)
    }

    private func kpiCard(icon: String, title: String, value: String) -> some View {
        VStack(spacing: 8) {

            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(Theme.primaryBlue))

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(Color(Theme.primaryBlue))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.07), radius: 3, y: 2)
    }

    // MARK: - Ticket Row (V1+ amélioré)
    private func ticketRow(_ t: Ticket) -> some View {
        HStack(alignment: .center, spacing: 12) {

            // petite icône cat
            Image(systemName: "receipt")
                .font(.system(size: 22))
                .foregroundColor(Color(Theme.primaryBlue))

            VStack(alignment: .leading, spacing: 6) {

                HStack {
                    Text(t.storeName)
                        .font(.headline)

                    Spacer()

                    Text(String(format: "%.2f €", t.amount))
                        .foregroundColor(Color(Theme.primaryBlue))
                        .fontWeight(.semibold)
                }

                Text(t.category)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(DateUtils.shortString(fromMillis: t.dateMillis))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "tray")
                .font(.system(size: 40))
                .foregroundColor(.gray)

            Text("Aucun ticket pour le moment.")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}
