import Foundation
import CoreData
import Combine

/// ViewModel dédié aux statistiques par catégorie (V2)
final class CategoryStatsViewModel: ObservableObject {

    // MARK: - Output
    @Published private(set) var totals: [CategoryTotal] = []
    @Published private(set) var grandTotal: Double = 0

    // MARK: - Filters
    @Published var startDate: Date? = nil
    @Published var endDate: Date? = nil

    // MARK: - Private
    private let context: NSManagedObjectContext
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(context: NSManagedObjectContext) {
        self.context = context

        // Recalcul automatique si Core Data change
        NotificationCenter.default.publisher(
            for: .NSManagedObjectContextDidSave,
            object: context
        )
        .sink { [weak self] _ in
            self?.reload()
        }
        .store(in: &cancellables)

        reload()
    }

    // MARK: - Public API
    func setRange(start: Date?, end: Date?) {
        startDate = start
        endDate = end
        reload()
    }

    func reload() {
        let request = NSFetchRequest<Ticket>(entityName: "Ticket")

        // Filtre date (dateMillis en ms)
        if let start = startDate, let end = endDate {
            let startMs = Int64(start.timeIntervalSince1970 * 1000)
            let endMs = Int64(end.timeIntervalSince1970 * 1000)
            request.predicate = NSPredicate(
                format: "dateMillis >= %lld AND dateMillis <= %lld",
                startMs,
                endMs
            )
        }

        request.sortDescriptors = [
            NSSortDescriptor(key: "dateMillis", ascending: false)
        ]

        do {
            let tickets = try context.fetch(request)

            var map: [String: Double] = [:]
            var total: Double = 0

            for ticket in tickets {
                let raw = ticket.category.trimmingCharacters(in: .whitespacesAndNewlines)
                let key = raw.isEmpty ? "Autre" : raw
                map[key, default: 0] += ticket.amount
                total += ticket.amount
            }

            let result = map
                .map { CategoryTotal(name: $0.key, total: $0.value) }
                .sorted { $0.total > $1.total }

            DispatchQueue.main.async {
                self.totals = result
                self.grandTotal = total
            }

        } catch {
            print("❌ CategoryStats fetch error:", error.localizedDescription)
            DispatchQueue.main.async {
                self.totals = []
                self.grandTotal = 0
            }
        }
    }
}
