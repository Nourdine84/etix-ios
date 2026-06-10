import Foundation

enum BudgetStore {

    private static let key = "categoryBudgets"
    private static var defaults: UserDefaults {
        UserDefaults(suiteName: "group.etix.shared") ?? .standard
    }

    static func load() -> [String: Double] {
        guard let data = defaults.data(forKey: key),
              let decoded = try? JSONDecoder().decode([String: Double].self, from: data)
        else { return [:] }
        return decoded
    }

    private static func save(_ budgets: [String: Double]) {
        guard let encoded = try? JSONEncoder().encode(budgets) else { return }
        defaults.set(encoded, forKey: key)
    }

    static func limit(for category: String) -> Double? {
        load()[category.lowercased()]
    }

    static func set(limit: Double?, for category: String) {
        var budgets = load()
        let normalizedKey = category.lowercased()
        if let limit, limit > 0 {
            budgets[normalizedKey] = limit
        } else {
            budgets.removeValue(forKey: normalizedKey)
        }
        save(budgets)
    }
}
