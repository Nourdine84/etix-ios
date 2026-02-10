import Foundation
import CoreData

final class StoreComparisonViewModel: ObservableObject {

    @Published var comparisons: [StoreComparisonItem] = []
    @Published var grandTotal: Double = 0

    func load(context: NSManagedObjectContext) {
        let request = Ticket.fetchAllRequest()

        do {
            let tickets = try context.fetch(request)

            let grouped = Dictionary(grouping: tickets, by: { $0.storeName ?? "Inconnu" })

            let totals = grouped.map { name, items -> (String, Double, Int) in
                let total = items.reduce(0) { $0 + $1.amount }
                return (name, total, items.count)
            }

            let global = totals.reduce(0) { $0 + $1.1 }
            self.grandTotal = global

            self.comparisons = totals
                .map { name, total, count in
                    StoreComparisonItem(
                        storeName: name,
                        total: total,
                        ticketCount: count,
                        percentOfTotal: global > 0 ? (total / global) * 100 : 0
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
