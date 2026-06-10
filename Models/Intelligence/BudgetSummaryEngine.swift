import Foundation

// MARK: - Modèle

enum BudgetState {
    case comfortable   // ratio < 0.50
    case caution       // 0.50 ≤ ratio < 0.80
    case critical      // 0.80 ≤ ratio < 1.00
    case exceeded      // ratio ≥ 1.00

    static func from(ratio: Double) -> BudgetState {
        if ratio >= 1.0 { return .exceeded }
        if ratio >= 0.80 { return .critical }
        if ratio >= 0.50 { return .caution }
        return .comfortable
    }
}

struct BudgetLine: Identifiable, Equatable {
    let categoryName: String
    let limit: Double
    let spent: Double
    let ratio: Double
    let state: BudgetState

    var id: String { categoryName }
}

struct BudgetSummary: Equatable {
    let totalBudget: Double
    let totalSpent: Double
    let remaining: Double
    let globalRatio: Double
    let daysLeftInMonth: Int
    let state: BudgetState
    let lines: [BudgetLine]      // max 3, triées par ratio décroissant
    let extraCount: Int          // budgets au-delà des 3 affichés
}

// MARK: - Moteur

/// Moteur pur — consomme les agrégats du HomeSnapshot, aucune boucle sur les
/// tickets, aucun accès CoreData. Calcul toujours basé sur le mois courant
/// (les budgets sont mensuels par définition — la condition d'affichage
/// range == .month est garantie par HomeView).
struct BudgetSummaryEngine {

    static func compute(
        snapshot: HomeSnapshot,
        budgets: [String: Double],
        now: Date = Date()
    ) -> BudgetSummary? {

        let validBudgets = budgets.filter { $0.value > 0 }
        guard !validBudgets.isEmpty else { return nil }

        var totalBudget: Double = 0
        var totalSpent: Double = 0
        var lines: [BudgetLine] = []

        for (key, limit) in validBudgets {
            // Jointure via lowercased — clés BudgetStore et categoryTotals déjà alignées
            let spent = snapshot.categoryTotals[key] ?? 0
            let ratio = spent / limit

            totalBudget += limit
            totalSpent += spent   // uniquement les catégories possédant un budget

            let displayName = snapshot.categoryDisplayNames[key] ?? key.capitalized
            lines.append(BudgetLine(
                categoryName: displayName,
                limit: limit,
                spent: spent,
                ratio: ratio,
                state: .from(ratio: ratio)
            ))
        }

        let globalRatio = totalSpent / totalBudget
        let sorted = lines.sorted { $0.ratio > $1.ratio }

        return BudgetSummary(
            totalBudget: totalBudget,
            totalSpent: totalSpent,
            remaining: totalBudget - totalSpent,
            globalRatio: globalRatio,
            daysLeftInMonth: snapshot.daysLeftInMonth,
            state: .from(ratio: globalRatio),
            lines: Array(sorted.prefix(3)),
            extraCount: max(0, sorted.count - 3)
        )
    }
}
