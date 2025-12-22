import Foundation
import CoreData
import Combine

final class CategoryViewModel: ObservableObject {
    @Published private(set) var totals: [CategoryTotal] = []
    @Published var startDate: Date? = nil
    @Published var endDate: Date? = nil

    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    init(context: NSManagedObjectContext) {
        self.context = context
        // Recalcul automatique quand Core Data change
        NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave, object: context)
            .sink { [weak self] _ in self?.reload() }
            .store(in: &cancellables)
        reload()
    }

    func setRange(start: Date?, end: Date?) {
        startDate = start
        endDate = end
        reload()
    }

    func reload() {
        let request = NSFetchRequest<Ticket>(entityName: "Ticket")
        // Filtre optionnel par plage de dates (en ms)
        if let s = startDate, let e = endDate {
            let startMs = Int64(s.timeIntervalSince1970 * 1000)
            let endMs   = Int64(e.timeIntervalSince1970 * 1000)
            request.predicate = NSPredicate(format: "dateMillis >= %lld AND dateMillis <= %lld", startMs, endMs)
        }
        request.sortDescriptors = [NSSortDescriptor(key: "dateMillis", ascending: false)]

        do {
            let data = try context.fetch(request)
            // Agrégation Swift : somme des montants par catégorie
            var map: [String: Double] = [:]
            for t in data {
                let key = t.category.trimmingCharacters(in: .whitespacesAndNewlines)
                map[key, default: 0.0] += t.amount
            }
            let list = map.map { CategoryTotal(name: $0.key.isEmpty ? "Autre" : $0.key, total: $0.value) }
                .sorted { $0.total > $1.total }
            DispatchQueue.main.async {
                self.totals = list
            }
        } catch {
            print("❌ Category fetch error:", error.localizedDescription)
            DispatchQueue.main.async { self.totals = [] }
        }
    }
}
