import Foundation
import CoreData

final class CategoryViewModel: ObservableObject {

    @Published var categories: [CategoryTotal] = []
    @Published var grandTotal: Double = 0

    func load(context: NSManagedObjectContext) {
        let request = Ticket.fetchAllRequest()

        do {
            let tickets = try context.fetch(request)

            let grouped = Dictionary(grouping: tickets) { $0.category }

            let mapped = grouped.map { key, values in
                CategoryTotal(
                    name: key,
                    total: values.reduce(0) { $0 + $1.amount }
                )
            }
            .sorted { $0.total > $1.total }

            DispatchQueue.main.async {
                self.categories = mapped
                self.grandTotal = mapped.reduce(0) { $0 + $1.total }
            }

        } catch {
            print("CategoryViewModel error:", error)
        }
    }
}
