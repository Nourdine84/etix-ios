import Foundation

/// Signaux d'entrée du moteur — volontairement réduits à des **scalaires
/// globaux**, pour que le moteur reste pur, testable **sans CoreData**, et
/// réutilisable par toute surface (Home, Widget, Watch…) capable de fournir ces
/// valeurs. Home les mappe depuis son `HomeSnapshot` / `BudgetSummary`.
struct FinancialInputs: Equatable {
    let periodTotal: Double
    let previousPeriodTotal: Double
    /// Nombre de tickets sur la **période courante** (≠ all-time). Un utilisateur
    /// mature peut avoir **0 ticket courant** : `currentTotal == 0` ne doit alors
    /// **pas** être interprété comme une économie.
    let currentPeriodTicketCount: Int
    let allTimeTicketCount: Int
    /// Budget global tendu (critique ou dépassé). `false` si aucun budget.
    let budgetTense: Bool
}

/// Évalue l'état financier **global**. Pur, sans UI, sans CoreData,
/// **indépendant des Insights** (n'importe rien de `HomeInsightEngine`, aucune
/// notion de catégorie ni de magasin).
///
/// Progressive Intelligence : le `kind` évolue avec la **maturité des données**,
/// jamais la structure d'affichage.
enum FinancialStateEngine {

    static func evaluate(_ inputs: FinancialInputs) -> FinancialState {
        // 1. Présence de données
        if inputs.allTimeTicketCount == 0 {
            return FinancialState(kind: .welcome, tone: .neutral)
        }

        // 2. Comparaison exploitable ? (maturité AVANT toute règle financière)
        //    Sinon → building, jamais steady/saving :
        //    - historique insuffisant,
        //    - aucun ticket sur la période courante (currentTotal == 0 ≠ économie),
        //    - aucune période précédente exploitable.
        let hasComparison =
            inputs.allTimeTicketCount >= 3 &&
            inputs.currentPeriodTicketCount > 0 &&
            inputs.previousPeriodTotal > 0
        guard hasComparison else {
            return FinancialState(kind: .building, tone: .neutral)
        }

        // 3. Tendance  —  4. état budgétaire (comparaison disponible).
        let delta = (inputs.periodTotal - inputs.previousPeriodTotal) / inputs.previousPeriodTotal

        // L'état ne dépend pas QUE du delta : un budget tendu escalade en attention.
        if delta >= 0.30 || inputs.budgetTense {
            return FinancialState(kind: .highSpending, tone: .attention)
        }
        if delta <= -0.15 {
            return FinancialState(kind: .saving, tone: .positive)
        }
        if delta >= 0.10 {
            return FinancialState(kind: .slightRise, tone: .neutral)
        }
        if delta < 0 {
            return FinancialState(kind: .underControl, tone: .positive)
        }
        return FinancialState(kind: .steady, tone: .neutral)
    }
}
