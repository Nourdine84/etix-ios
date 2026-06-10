import Foundation
import CoreData

final class StoreListViewModel: ObservableObject {

    @Published var stores: [StoreTotal] = []
    @Published var grandTotal: Double = 0

    func load(categoryName: String, context: NSManagedObjectContext, range: TimeRange) {
        let request = Ticket.fetchAllRequest()

        do {
            let r = DateRangeHelper.currentRange(for: range)
            let startMs = DateRangeHelper.millis(r.start)
            let endMs   = DateRangeHelper.millis(r.end)

            let tickets = try context.fetch(request)
                .filter { categoryName.isEmpty || $0.category == categoryName }
                .filter { $0.dateMillis >= startMs && $0.dateMillis < endMs }

            let results = Dictionary(grouping: tickets, by: { $0.storeName })
                .map { key, values in
                    StoreTotal(
                        storeName: key,
                        total: values.reduce(0) { $0 + $1.amount },
                        ticketCount: values.count,
                        lastPurchaseMillis: values.map { $0.dateMillis }.max() ?? 0
                    )
                }
                .sorted { $0.total > $1.total }

            self.stores = results
            self.grandTotal = results.reduce(0) { $0 + $1.total }

        } catch {
            self.stores = []
            self.grandTotal = 0
        }
    }
}
