import Foundation
import CoreData

final class StoreComparisonViewModel: ObservableObject {

    // MARK: - Published
    @Published var comparisons: [StoreComparisonItem] = []
    @Published private(set) var grandTotal: Double = 0

    // MARK: - Alias sûr pour les vues
    var total: Double {
        grandTotal
    }

    // MARK: - Load
    func load(context: NSManagedObjectContext) {
        let request = Ticket.fetchAllRequest()

        do {
            let tickets = try context.fetch(request)

            let grouped = Dictionary(
                grouping: tickets,
                by: { $0.storeName ?? "Inconnu" }
            )

            let totals = grouped.map { name, items -> StoreComparisonItem in
                let total = items.reduce(0) { $0 + $1.amount }
                return StoreComparisonItem(
                    storeName: name,
                    total: total,
                    ticketCount: items.count,
                    percentOfTotal: 0 // recalculé après
                )
            }

            let global = totals.reduce(0) { $0 + $1.total }
            self.grandTotal = global

            self.comparisons = totals
                .map {
                    StoreComparisonItem(
                        storeName: $0.storeName,
                        total: $0.total,
                        ticketCount: $0.ticketCount,
                        percentOfTotal: global > 0
                            ? ($0.total / global) * 100
                            : 0
                    )
                }
                .sorted { $0.total > $1.total }

        } catch {
            self.comparisons = []
            self.grandTotal = 0
        }
    }

    // MARK: - Insights
    var highestStore: StoreComparisonItem? {
        comparisons.first
    }

    var lowestStore: StoreComparisonItem? {
        comparisons.last
    }

    var delta: Double {
        guard let max = highestStore, let min = lowestStore else { return 0 }
        return max.total - min.total
    }
}
