import Foundation
import CoreData

final class StoreComparisonViewModel: ObservableObject {

    @Published var comparisons: [StoreComparison] = []
    @Published var grandTotal: Double = 0

    func load(context: NSManagedObjectContext) {

        let request = Ticket.fetchAllRequest()

        do {
            let tickets = try context.fetch(request)
            let grouped = Dictionary(grouping: tickets, by: { $0.storeName ?? "Inconnu" })

            let totals = grouped.map { key, values in
                (
                    store: key,
                    total: values.reduce(0) { $0 + $1.amount },
                    count: values.count
                )
            }
            .sorted { $0.total > $1.total }

            let global = totals.reduce(0) { $0 + $1.total }
            self.grandTotal = global

            self.comparisons = totals.enumerated().map { index, item in
                StoreComparison(
                    rank: index + 1,
                    storeName: item.store,
                    total: item.total,
                    percent: global > 0 ? (item.total / global) * 100 : 0,
                    ticketCount: item.count
                )
            }

        } catch {
            self.comparisons = []
            self.grandTotal = 0
        }
    }
}
