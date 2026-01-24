import Foundation
import CoreData

final class StoreListViewModel: ObservableObject {

    @Published var stores: [StoreTotal] = []
    @Published var grandTotal: Double = 0

    func load(categoryName: String, context: NSManagedObjectContext) {

        let request = Ticket.fetchAllRequest()

        do {
            let tickets = try context.fetch(request)
                .filter { categoryName.isEmpty || $0.category == categoryName }

            let grouped = Dictionary(grouping: tickets, by: { $0.storeName })

            let results = grouped.map { key, values in
                StoreTotal(
                    storeName: key,
                    total: values.reduce(0) { $0 + $1.amount },
                    ticketCount: values.count
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
