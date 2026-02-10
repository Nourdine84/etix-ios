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

            let totals = grouped.map { name, items -> StoreComparisonItem in
                let total = items.reduce(0) { $0 + $1.amount }
                return StoreComparisonItem(
                    storeName: name,
                    total: total,
                    ticketCount: items.count,
                    sharePercent: 0 // calcul après
                )
            }

            let global = totals.reduce(0) { $0 + $1.total }

            self.comparisons = totals.map {
                StoreComparisonItem(
                    storeName: $0.storeName,
                    total: $0.total,
                    ticketCount: $0.ticketCount,
                    sharePercent: global > 0 ? ($0.total / global) * 100 : 0
                )
            }
            .sorted { $0.total > $1.total }

            self.grandTotal = global

        } catch {
            self.comparisons = []
            self.grandTotal = 0
        }
    }
}
