import SwiftUI
import CoreData

struct CategoryStatsView: View {
    @Environment(\.managedObjectContext) private var context

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(key: "dateMillis", ascending: false)
        ],
        animation: .default
    )
    private var tickets: FetchedResults<Ticket>

    // MARK: - Agrégats

    private var grandTotal: Double {
        tickets.reduce(0) { $0 + $1.amount }
    }

    private var summaries: [CategorySummary] {
        // Regroupement par catégorie (vide = "Autre")
        let grouped = Dictionary(grouping: tickets) { (ticket: Ticket) -> String in
            let raw = ticket.category
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return raw.isEmpty ? "Autre" : raw
        }

        let totalAll = grandTotal
        var result: [CategorySummary] = []

        for (name, items) in grouped {
            let total = items.reduce(0) { $0 + $1.amount }
            let count = items.count
            let percent = totalAll > 0 ? (total / totalAll) * 100.0 : 0

            result.append(
                CategorySummary(
                    name: name,
                    total: total,
                    count: count,
                    percent: percent
                )
            )
        }

        // Tri par montant décroissant
        return result.sorted { $0.total > $1.total }
    }

    // MARK: - Body

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {

                    headerTotal

                    if tickets.isEmpty {
                        emptyState
                    } else {
                        VStack(spacing: 12) {
                            ForEach(summaries) { summary in
                                CategoryRow(
                                    summary: summary,
                                    grandTotal: grandTotal
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.bottom, 16)
                    }
                }
                .padding(.top, 16)
            }
            .navigationTitle("Catégories")
        }
    }

    // MARK: - Header Total

    private var headerTotal: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Total général")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(String(format: "%.2f €", grandTotal))
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(Theme.primaryBlue))

            Text("\(tickets.count) ticket\(tickets.count > 1 ? "s" : "")")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        .padding(.horizontal)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 40))
                .foregroundColor(.gray)

            Text("Aucune catégorie disponible")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Text("Ajoute quelques tickets pour voir la répartition par catégorie.")
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Modèle local

private struct CategorySummary: Identifiable {
    let id = UUID()
    let name: String
    let total: Double
    let count: Int
    let percent: Double
}

// MARK: - Row UI

private struct CategoryRow: View {
    let summary: CategorySummary
    let grandTotal: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text(summary.name)
                    .font(.headline)

                Spacer()

                Text(String(format: "%.2f €", summary.total))
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color(Theme.primaryBlue))
            }

            HStack {
                Text("\(summary.count) ticket\(summary.count > 1 ? "s" : "")")
                    .font(.footnote)
                    .foregroundColor(.secondary)

                Spacer()

                Text(String(format: "%.0f %%", summary.percent))
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5))
                    Capsule()
                        .fill(Color(Theme.primaryBlue).opacity(0.85))
                        .frame(width: barWidth(in: geo.size.width))
                }
            }
            .frame(height: 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(14)
        .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
    }

    private func barWidth(in fullWidth: CGFloat) -> CGFloat {
        guard grandTotal > 0 else { return 0 }
        let ratio = summary.total / grandTotal
        return max(4, fullWidth * CGFloat(min(max(ratio, 0), 1)))
    }
}
