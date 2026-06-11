import Foundation

// MARK: - Modèle

enum InsightType: Int, Comparable, CaseIterable {
    case budgetExceeded  = 1
    case budgetCritical  = 2
    case unusualSpending = 3
    case dominantStore   = 4
    case captureReminder = 5
    case biggestPurchase = 6
    case goodMonth       = 7
    case budgetsHealthy  = 8
    case newStore        = 9

    static func < (lhs: InsightType, rhs: InsightType) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

enum InsightSeverity {
    case critical
    case warning
    case neutral
    case positive
}

enum InsightDestination: Equatable {
    case categoryDetail(name: String)
    case storeDetail(name: String)
    case monthlyReport
    case none
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
/// Évalue les 9 règles V1.4.1 et retourne au maximum 2 insights triés par priorité.
struct HomeInsightEngine {

    static func evaluate(
        snapshot: HomeSnapshot,
        budgets: [String: Double],
        range: TimeRange,
        storeIntelligence: StoreIntelligence? = nil,
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

        var hasUnusualSpending = false
        if let unusual = unusualSpending(snapshot: snapshot, range: range),
           !InsightMemory.isSuppressed(.unusualSpending, now: now) {
            insights.append(unusual)
            hasUnusualSpending = true
        }

        if let dominant = dominantStore(snapshot: snapshot, range: range) {
            insights.append(dominant)
        }

        if let capture = captureReminder(snapshot: snapshot, now: now),
           !InsightMemory.isSuppressed(.captureReminder, now: now) {
            insights.append(capture)
        }

        if let biggest = biggestPurchase(snapshot: snapshot) {
            insights.append(biggest)
        }

        // Exclusion mutuelle : goodMonth jamais en même temps qu'unusualSpending
        if !hasUnusualSpending,
           let good = goodMonth(snapshot: snapshot, range: range, now: now),
           !InsightMemory.isSuppressed(.goodMonth, now: now) {
            insights.append(good)
        }

        if let healthy = budgetsHealthy(snapshot: snapshot, budgets: budgets, range: range, now: now),
           !InsightMemory.isSuppressed(.budgetsHealthy, now: now) {
            insights.append(healthy)
        }

        // Exclusion : newStore supprimé si la Store Intelligence Card affiche déjà newMerchant
        if storeIntelligence?.kind != .newMerchant,
           let newStore = newStore(snapshot: snapshot, now: now) {
            insights.append(newStore)
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

    // MARK: - Règle 5 : Rappel de capture (aucun ticket depuis 72h)

    private static func captureReminder(
        snapshot: HomeSnapshot,
        now: Date
    ) -> HomeInsight? {
        // Exclusion : jamais pour un utilisateur sans aucun ticket
        guard snapshot.allTimeTicketCount > 0,
              snapshot.lastTicketMillis > 0 else { return nil }

        let nowMs = Int64(now.timeIntervalSince1970 * 1000)
        let elapsedMs = nowMs - snapshot.lastTicketMillis
        guard elapsedMs > 72 * 3600 * 1000 else { return nil }

        let days = Int(elapsedMs / (24 * 3600 * 1000))
        return HomeInsight(
            id: .captureReminder,
            title: "Dernier ticket il y a \(days) jour\(days > 1 ? "s" : "")",
            subtitle: "Quelque chose à scanner ?",
            severity: .neutral,
            icon: "camera.viewfinder",
            destination: .none
        )
    }

    // MARK: - Règle 6 : Plus gros achat (> 2 × moyenne période)

    private static func biggestPurchase(snapshot: HomeSnapshot) -> HomeInsight? {
        // Sous 3 tickets, max > 2 × moyenne est mathématiquement impossible
        guard snapshot.periodTicketCount >= 3,
              snapshot.maxPeriodTicketAmount > 0 else { return nil }

        let average = snapshot.periodTotal / Double(snapshot.periodTicketCount)
        guard snapshot.maxPeriodTicketAmount > average * 2 else { return nil }

        return HomeInsight(
            id: .biggestPurchase,
            title: "Plus gros achat de la période",
            subtitle: "\(euros(snapshot.maxPeriodTicketAmount)) chez \(snapshot.maxPeriodTicketStore)",
            severity: .neutral,
            icon: "creditcard",
            destination: .none
        )
    }

    // MARK: - Règle 7 : Excellent mois (-15% après le 15)

    private static func goodMonth(
        snapshot: HomeSnapshot,
        range: TimeRange,
        now: Date
    ) -> HomeInsight? {
        guard range == .month,
              Calendar.current.component(.day, from: now) > 15,
              snapshot.previousPeriodTotal > 0,
              snapshot.periodTotal < snapshot.previousPeriodTotal * 0.85 else { return nil }

        let deltaPercent = Int(
            ((snapshot.previousPeriodTotal - snapshot.periodTotal) / snapshot.previousPeriodTotal) * 100
        )
        return HomeInsight(
            id: .goodMonth,
            title: "Excellent mois",
            subtitle: "-\(deltaPercent) % vs période précédente",
            severity: .positive,
            icon: "checkmark.seal.fill",
            destination: .monthlyReport
        )
    }

    // MARK: - Règle 8 : Budgets maîtrisés (tous < 60% après le 20)

    private static func budgetsHealthy(
        snapshot: HomeSnapshot,
        budgets: [String: Double],
        range: TimeRange,
        now: Date
    ) -> HomeInsight? {
        guard range == .month,
              Calendar.current.component(.day, from: now) > 20 else { return nil }

        let validBudgets = budgets.filter { $0.value > 0 }
        guard !validBudgets.isEmpty else { return nil }

        for (key, limit) in validBudgets {
            let spent = snapshot.categoryTotals[key] ?? 0
            guard spent / limit < 0.60 else { return nil }
        }

        return HomeInsight(
            id: .budgetsHealthy,
            title: "Budgets maîtrisés",
            subtitle: "Tous les budgets sont sous contrôle",
            severity: .positive,
            icon: "checkmark.seal.fill",
            destination: .none
        )
    }

    // MARK: - Règle 9 : Nouveau magasin (1 ticket all-time < 7 jours)

    private static func newStore(
        snapshot: HomeSnapshot,
        now: Date
    ) -> HomeInsight? {
        let nowMs = Int64(now.timeIntervalSince1970 * 1000)
        let sevenDaysMs: Int64 = 7 * 24 * 3600 * 1000

        var best: (store: String, lastMs: Int64)?
        for (store, count) in snapshot.storeAllTimeCounts where count == 1 {
            guard let lastMs = snapshot.storeLastVisitMillis[store],
                  nowMs - lastMs < sevenDaysMs else { continue }
            // Plusieurs candidats possibles → le plus récent
            if lastMs > (best?.lastMs ?? Int64.min) { best = (store, lastMs) }
        }
        guard let b = best else { return nil }

        return HomeInsight(
            id: .newStore,
            title: "Nouveau magasin",
            subtitle: "Première visite enregistrée",
            severity: .neutral,
            icon: "sparkles",
            destination: .storeDetail(name: b.store)
        )
    }

    // MARK: - Helpers

    private static func euros(_ value: Double) -> String {
        String(format: "%.0f €", value)
    }
}
