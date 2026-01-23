import Foundation
import CoreData

final class HomeKPIViewModel: ObservableObject {

    @Published var todayTotal: Double = 0
    @Published var monthTotal: Double = 0
    @Published var todayComparison: KPIComparison?
    @Published var monthComparison: KPIComparison?

    func load(context: NSManagedObjectContext) {
        let tickets = (try? context.fetch(Ticket.fetchAllRequest())) ?? []
        let calendar = Calendar.current
        let now = Date()

        // TODAY
        let startToday = calendar.startOfDay(for: now)
        let startYesterday = calendar.date(byAdding: .day, value: -1, to: startToday)!

        let today = sum(from: startToday, tickets: tickets)
        let yesterday = sum(from: startYesterday, to: startToday, tickets: tickets)

        todayTotal = today
        todayComparison = compare(current: today, previous: yesterday, label: "vs hier")

        // MONTH
        let startMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let startLastMonth = calendar.date(byAdding: .month, value: -1, to: startMonth)!

        let month = sum(from: startMonth, tickets: tickets)
        let lastMonth = sum(from: startLastMonth, to: startMonth, tickets: tickets)

        monthTotal = month
        monthComparison = compare(current: month, previous: lastMonth, label: "vs mois dernier")
    }

    private func sum(from start: Date, to end: Date? = nil, tickets: [Ticket]) -> Double {
        let startMs = Int64(start.timeIntervalSince1970 * 1000)
        let endMs = end.map { Int64($0.timeIntervalSince1970 * 1000) }

        return tickets
            .filter {
                $0.dateMillis >= startMs &&
                (endMs == nil || $0.dateMillis < endMs!)
            }
            .reduce(0) { $0 + $1.amount }
    }

    private func compare(current: Double, previous: Double, label: String) -> KPIComparison {
        guard previous > 0 else {
            return KPIComparison(label: label, deltaPercent: 0)
        }
        let delta = ((current - previous) / previous) * 100
        return KPIComparison(label: label, deltaPercent: delta)
    }
}
