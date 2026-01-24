import Foundation
import CoreData

final class StoreComparisonViewModel: ObservableObject {

    @Published var stores: [StoreTotal] = []

    func load(context: NSManagedObjectContext) {
        let request = Ticket.fetchAllRequest()

        do {
            let tickets = try context.fetch(request)

            let grouped = Dictionary(grouping: tickets) { $0.storeName ?? "Inconnu" }

            let results = grouped.map { key, values in
                StoreTotal(
                    storeName: key,
                    total: values.reduce(0) { $0 + $1.amount },
                    ticketCount: values.count
                )
            }
            .sorted { $0.total > $1.total }

            self.stores = results
        } catch {
            self.stores = []
        }
    }
}
