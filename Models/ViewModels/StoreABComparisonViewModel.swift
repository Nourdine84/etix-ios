import Foundation
import CoreData

final class StoreABComparisonViewModel: ObservableObject {

    // MARK: - Selection
    @Published var storeA: String?
    @Published var storeB: String?

    // MARK: - Data
    @Published private(set) var itemA: StoreABComparisonItem?
    @Published private(set) var itemB: StoreABComparisonItem?

    // MARK: - Load
    func load(context: NSManagedObjectContext) {
        guard let storeA, let storeB else { return }

        let request = Ticket.fetchAllRequest()

        do {
            let tickets = try context.fetch(request)

            itemA = buildItem(for: storeA, tickets: tickets)
            itemB = buildItem(for: storeB, tickets: tickets)

        } catch {
            itemA = nil
            itemB = nil
        }
    }

    private func buildItem(
        for store: String,
        tickets: [Ticket]
    ) -> StoreABComparisonItem {

        let filtered = tickets.filter { $0.storeName == store }

        let total = filtered.reduce(0) { $0 + $1.amount }

        return StoreABComparisonItem(
            storeName: store,
            total: total,
            ticketCount: filtered.count
        )
    }

    // MARK: - Insights
    var deltaTotal: Double {
        guard let a = itemA, let b = itemB else { return 0 }
        return a.total - b.total
    }

    var deltaPercent: Double {
        guard
            let a = itemA,
            let b = itemB,
            b.total > 0
        else { return 0 }

        return ((a.total - b.total) / b.total) * 100
    }
}
