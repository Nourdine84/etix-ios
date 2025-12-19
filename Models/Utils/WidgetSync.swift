import Foundation
import CoreData
import WidgetKit

enum WidgetSync {
    // ⚠️ mets ici ton App Group exact
    private static let suiteID = "group.etix.shared"

    static func updateSnapshot(context: NSManagedObjectContext) {
        let ud = UserDefaults(suiteName: suiteID)

        let cal = Calendar.current
        let now = Date()
        let comps = cal.dateComponents([.year, .month], from: now)
        let monthStart = cal.date(from: comps) ?? now
        let startMs = Int64(monthStart.timeIntervalSince1970 * 1000)
        let endMs = Int64(now.timeIntervalSince1970 * 1000)

        let req = NSFetchRequest<Ticket>(entityName: "Ticket")
        req.predicate = NSPredicate(format: "dateMillis >= %lld AND dateMillis <= %lld", startMs, endMs)
        do {
            let rows = try context.fetch(req)
            let total = rows.reduce(0.0) { $0 + $1.amount }
            let count = rows.count

            // Label localisé genre "Oct. 2025"
            let df = DateFormatter()
            df.locale = .current
            df.setLocalizedDateFormatFromTemplate("MMM yyyy")
            let label = df.string(from: monthStart).capitalized

            ud?.set(total, forKey: "monthTotal")
            ud?.set(count, forKey: "monthCount")
            ud?.set(label, forKey: "monthLabel")
            ud?.set(Date().timeIntervalSince1970, forKey: "updatedAt")
            ud?.synchronize()

            // Demande au widget de se rafraîchir
            WidgetCenter.shared.reloadAllTimelines()

        } catch {
            print("WidgetSync error:", error.localizedDescription)
        }
    }
}
