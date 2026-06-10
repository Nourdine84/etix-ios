import Foundation

// MARK: - Modèle

enum InsightType: Int, Comparable, CaseIterable {
    case budgetExceeded  = 1
    case budgetCritical  = 2
    case unusualSpending = 3
    case dominantStore   = 4

    static func < (lhs: InsightType, rhs: InsightType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

enum InsightSeverity {
    case critical
    case warning
    case neutral
}

enum InsightDestination: Equatable {
    case categoryDetail(name: String)
    case storeDetail(name: String)
    case monthlyReport
}

struct HomeInsight: Identifiable, Equatable {
    let id: InsightType
    let title: String
    let subtitle: String
    let severity: InsightSeverity
    let icon: String
    let destination: InsightDestination
}

// MARK: - Moteur

/// Moteur pur — aucune dépendance UI, aucun état.
/// Évalue les 4 règles du Sprint 1 et retourne au maximum 2 insights triés par priorité.
struct HomeInsightEngine {

    static func evaluate(
        snapshot: HomeSnapshot,
        budgets: [String: Double],
        range: TimeRange,
        now: Date = Date()
    ) -> [HomeInsight] {

        // Garde-fou global : silence total sous 3 tickets all-time
        guard snapshot.allTimeTicketCount >= 3 else { return [] }

        var insights: [HomeInsight] = []

        if let exceeded = budgetExceeded(snapshot: snapshot, budgets: budgets, range: range) {
            // État d'urgence : l'insight budget dépassé est affiché seul
            return [exceeded]
        }

        if let critical = budgetCritical(snapshot: snapshot, budgets: budgets, range: range) {
            insights.append(critical)
        }

        if let unusual = unusualSpending(snapshot: snapshot, range: range),
           !InsightMemory.isSuppressed(.unusualSpending, now: now) {
            insights.append(unusual)
        }

        if let dominant = dominantStore(snapshot: snapshot, range: range) {
            insights.append(dominant)
        }

        return Array(insights.sorted { $0.id < $1.id }.prefix(2))
    }

    // MARK: - Règle 1 : Budget dépassé

    private static func budgetExceeded(
        snapshot: HomeSnapshot,
        budgets: [String: Double],
        range: TimeRange
    ) -> HomeInsight? {
        guard range == .month, !budgets.isEmpty else { return nil }

        var worst: (key: String, spent: Double, limit: Double, overshoot: Double)?
        for (key, limit) in budgets where limit > 0 {
            let spent = snapshot.categoryTotals[key] ?? 0
            let overshoot = spent - limit
            if overshoot > 0 && overshoot > (worst?.overshoot ?? 0) {
                worst = (key, spent, limit, overshoot)
            }
        }
        guard let w = worst else { return nil }

        let name = snapshot.categoryDisplayNames[w.key] ?? w.key.capitalized
        return HomeInsight(
            id: .budgetExceeded,
            title: "Budget \(name) dépassé de \(euros(w.overshoot))",
            subtitle: "\(euros(w.spent)) dépensés · limite \(euros(w.limit))",
            severity: .critical,
            icon: "exclamationmark.circle.fill",
            destination: .categoryDetail(name: name)
        )
    }

    // MARK: - Règle 2 : Budget critique (≥ 80%)

    private static func budgetCritical(
        snapshot: HomeSnapshot,
        budgets: [String: Double],
        range: TimeRange
    ) -> HomeInsight? {
        guard range == .month, !budgets.isEmpty,
              snapshot.daysLeftInMonth > 3 else { return nil }

        var worst: (key: String, spent: Double, limit: Double, ratio: Double)?
        for (key, limit) in budgets where limit > 0 {
            let spent = snapshot.categoryTotals[key] ?? 0
            let ratio = spent / limit
            if ratio >= 0.80 && ratio < 1.0 && ratio > (worst?.ratio ?? 0) {
                worst = (key, spent, limit, ratio)
            }
        }
        guard let w = worst else { return nil }

        let name = snapshot.categoryDisplayNames[w.key] ?? w.key.capitalized
        let remaining = w.limit - w.spent
        return HomeInsight(
            id: .budgetCritical,
            title: "Budget \(name) à \(Int(w.ratio * 100))% — il reste \(snapshot.daysLeftInMonth) j",
            subtitle: "\(euros(remaining)) encore disponibles",
            severity: .warning,
            icon: "chart.line.uptrend.xyaxis",
            destination: .categoryDetail(name: name)
        )
    }

    // MARK: - Règle 3 : Dépense inhabituelle (+30%)

    private static func unusualSpending(
        snapshot: HomeSnapshot,
        range: TimeRange
    ) -> HomeInsight? {
        guard range != .today,
              snapshot.previousPeriodTotal > 0,
              snapshot.periodTotal > snapshot.previousPeriodTotal * 1.30 else { return nil }

        let deltaPercent = Int(
            ((snapshot.periodTotal - snapshot.previousPeriodTotal) / snapshot.previousPeriodTotal) * 100
        )
        let (title, comparisonLabel): (String, String) = range == .month
            ? ("Ce mois-ci tu dépenses \(deltaPercent)% de plus que d'habitude", "le mois dernier")
            : ("Cette année tu dépenses \(deltaPercent)% de plus", "l'année dernière")

        return HomeInsight(
            id: .unusualSpending,
            title: title,
            subtitle: "\(euros(snapshot.periodTotal)) vs \(euros(snapshot.previousPeriodTotal)) \(comparisonLabel)",
            severity: .warning,
            icon: "arrow.up.right.circle",
            destination: .monthlyReport
        )
    }

    // MARK: - Règle 4 : Magasin dominant (≥ 40%)

    private static func dominantStore(
        snapshot: HomeSnapshot,
        range: TimeRange
    ) -> HomeInsight? {
        guard range != .today, snapshot.periodTotal > 0 else { return nil }

        guard let (store, total) = snapshot.storeTotals.max(by: { $0.value < $1.value })
        else { return nil }

        let share = total / snapshot.periodTotal
        let count = snapshot.storeTicketCounts[store] ?? 0

        // ≥ 40% du total, ≥ 3 tickets — et suppression au-delà de 80% (anti-bruit :
        // l'info n'apprend rien à qui ne fréquente qu'un seul magasin)
        guard share >= 0.40, share <= 0.80, count >= 3 else { return nil }

        return HomeInsight(
            id: .dominantStore,
            title: "\(store) représente \(Int(share * 100))% de tes dépenses",
            subtitle: "\(count) passage\(count > 1 ? "s" : "") · \(euros(total))",
            severity: .neutral,
            icon: "building.2",
            destination: .storeDetail(name: store)
        )
    }

    // MARK: - Helpers

    private static func euros(_ value: Double) -> String {
        String(format: "%.0f €", value)
    }
}
