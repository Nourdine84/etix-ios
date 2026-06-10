import Foundation
import CoreData

final class CategoryViewModel: ObservableObject {

    @Published var categories: [CategoryTotal] = []
    @Published var grandTotal: Double = 0

    func load(context: NSManagedObjectContext, range: TimeRange) {
        let request = Ticket.fetchAllRequest()

        do {
            let allTickets = try context.fetch(request)

            let current = DateRangeHelper.currentRange(for: range)
            let currentStart = DateRangeHelper.millis(current.start)
            let currentEnd   = DateRangeHelper.millis(current.end)

            let previous = DateRangeHelper.previousRange(for: range)
            let prevStart = DateRangeHelper.millis(previous.start)
            let prevEnd   = DateRangeHelper.millis(previous.end)

            let currentTickets = allTickets.filter {
                $0.dateMillis >= currentStart && $0.dateMillis < currentEnd
            }
            let previousTickets = allTickets.filter {
                $0.dateMillis >= prevStart && $0.dateMillis < prevEnd
            }

            let prevTotals = Dictionary(grouping: previousTickets) { $0.category }
                .mapValues { $0.reduce(0) { $0 + $1.amount } }

            let mapped = Dictionary(grouping: currentTickets) { $0.category }
                .map { key, values in
                    CategoryTotal(
                        name: key,
                        total: values.reduce(0) { $0 + $1.amount },
                        previousTotal: prevTotals[key] ?? 0
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
