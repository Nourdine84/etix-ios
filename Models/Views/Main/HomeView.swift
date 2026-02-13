import SwiftUI
import CoreData

struct HomeView: View {

    // MARK: - CoreData
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(fetchRequest: Ticket.fetchAllRequest())
    private var tickets: FetchedResults<Ticket>

    // MARK: - Calculs

    private var monthTickets: [Ticket] {
        let calendar = Calendar.current
        let now = Date()
        let comps = calendar.dateComponents([.year, .month], from: now)
        guard let start = calendar.date(from: comps) else { return [] }

        let startMs = Int64(start.timeIntervalSince1970 * 1000)

        return tickets.filter { $0.dateMillis >= startMs }
    }

    private var monthTotal: Double {
        monthTickets.reduce(0) { $0 + $1.amount }
    }

    private var ticketCount: Int {
        monthTickets.count
    }

    private var average: Double {
        guard ticketCount > 0 else { return 0 }
        return monthTotal / Double(ticketCount)
    }

    // MARK: - Donut Data

    private var slices: [DonutSlice] {
        let grouped = Dictionary(grouping: monthTickets, by: { $0.storeName ?? "Inconnu" })

        let totals = grouped.map { key, value in
            (key, value.reduce(0) { $0 + $1.amount })
        }

        let grandTotal = totals.reduce(0) { $0 + $1.1 }

        var start: Double = 0
        var result: [DonutSlice] = []

        for item in totals.sorted(by: { $0.1 > $1.1 }) {
            let percent = grandTotal > 0 ? item.1 / grandTotal : 0
            let end = start + percent

            result.append(
                DonutSlice(
                    id: UUID(),
                    label: item.0,
                    value: item.1,
                    startAngle: start,
                    endAngle: end
                )
            )

            start = end
        }

        return result
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // HEADER
                    VStack(alignment: .leading, spacing: 6) {
                        Text("eTix")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Vue d'ensemble")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // KPI PRINCIPAL
                    VStack(alignment: .leading, spacing: 12) {

                        Text("Dépenses du mois")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(String(format: "%.2f €", monthTotal))
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("\(ticketCount) ticket(s)")
                            .font(.caption)
                            .foregroundColor(.secondary)

                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 5)
                    )

                    // DONUT
                    VStack(alignment: .leading, spacing: 16) {

                        Text("Répartition par magasin")
                            .font(.headline)

                        ZStack {

                            Circle()
                                .stroke(Color(.systemGray5), lineWidth: 26)

                            ForEach(slices) { slice in
                                DonutSliceView(slice: slice)
                            }

                            VStack {
                                Text(String(format: "%.2f €", monthTotal))
                                    .font(.title2)
                                    .fontWeight(.bold)

                                Text("Total")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(height: 220)
                    }

                    // KPI SECONDAIRES
                    HStack(spacing: 16) {

                        VStack(spacing: 8) {
                            Text("Tickets")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("\(ticketCount)")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        )

                        VStack(spacing: 8) {
                            Text("Moyenne")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(String(format: "%.2f €", average))
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 30)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
    }
}
