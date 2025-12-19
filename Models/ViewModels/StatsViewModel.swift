import Foundation
import CoreData

final class StatsViewModel: ObservableObject {
    @Published private(set) var stats: [MonthlyStat] = []
    @Published private(set) var topCategories: [(name: String, total: Double)] = []
    @Published var monthsBack: Int = 12 { didSet { reload() } }

    private let context: NSManagedObjectContext
    private let cal = Calendar.current

    init(context: NSManagedObjectContext) {
        self.context = context
        reload()
    }

    func reload() {
        let endDate = Date()
        guard let startDate = cal.date(byAdding: .month, value: -monthsBack + 1,
                                       to: firstDayOfMonth(for: endDate)) else {
            DispatchQueue.main.async {
                self.stats = []
                self.topCategories = []
            }
            return
        }

        // --- Fetch Core Data dans la fenêtre sélectionnée
        let req = NSFetchRequest<Ticket>(entityName: "Ticket")
        let startMs = Int64(startDate.timeIntervalSince1970 * 1000)
        let endMs   = Int64(endDate.timeIntervalSince1970 * 1000)
        req.predicate = NSPredicate(format: "dateMillis >= %lld AND dateMillis <= %lld", startMs, endMs)
        req.sortDescriptors = [NSSortDescriptor(key: "dateMillis", ascending: true)]

        do {
            let rows = try context.fetch(req)

            // --- Group by mois
            var byMonth: [String:(sum: Double, count: Int, date: Date)] = [:]
            for t in rows {
                let d = Date(timeIntervalSince1970: TimeInterval(t.dateMillis) / 1000.0)
                let m0 = firstDayOfMonth(for: d)
                let key = monthKey(for: m0)
                var e = byMonth[key] ?? (0, 0, m0)
                e.sum += t.amount
                e.count += 1
                byMonth[key] = e
            }

            // Génère tous les mois (y compris vides)
            var out: [MonthlyStat] = []
            var cursor = firstDayOfMonth(for: startDate)
            let endM = firstDayOfMonth(for: endDate)
            while cursor <= endM {
                let key = monthKey(for: cursor)
                let label = monthLabel(for: cursor)
                let v = byMonth[key] ?? (0, 0, cursor)
                out.append(MonthlyStat(monthKey: key, monthLabel: label, totalAmount: v.sum, ticketCount: v.count))
                cursor = cal.date(byAdding: .month, value: 1, to: cursor)!
            }

            // --- Top catégories sur la même fenêtre
            var byCat: [String: Double] = [:]
            for t in rows {
                let key = t.category.trimmingCharacters(in: .whitespacesAndNewlines)
                byCat[key.isEmpty ? "Autre" : key, default: 0.0] += t.amount
            }
            let top3 = byCat
                .map { (name: $0.key, total: $0.value) }
                .sorted { $0.total > $1.total }
                .prefix(3)

            DispatchQueue.main.async {
                self.stats = out.sorted { $0.monthKey < $1.monthKey }
                self.topCategories = Array(top3)
            }
        } catch {
            print("❌ Stats fetch error:", error.localizedDescription)
            DispatchQueue.main.async {
                self.stats = []
                self.topCategories = []
            }
        }
    }

    // MARK: - Helpers
    private func firstDayOfMonth(for date: Date) -> Date {
        let c = cal.dateComponents([.year, .month], from: date)
        return cal.date(from: c) ?? date
    }
    private func monthKey(for date: Date) -> String {
        let c = cal.dateComponents([.year, .month], from: date)
        return String(format: "%04d-%02d", c.year ?? 0, c.month ?? 0)
    }
    private func monthLabel(for date: Date) -> String {
        let fmt = DateFormatter()
        fmt.locale = Locale.current
        fmt.setLocalizedDateFormatFromTemplate("MMM yyyy")
        return fmt.string(from: date).capitalized
    }
}
