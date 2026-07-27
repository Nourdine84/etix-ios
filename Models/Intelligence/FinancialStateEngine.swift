import Foundation

/// Signaux d'entrée du moteur — volontairement réduits à des **scalaires
/// globaux**, pour que le moteur reste pur, testable **sans CoreData**, et
/// réutilisable par toute surface (Home, Widget, Watch…) capable de fournir ces
/// valeurs. Home les mappe depuis son `HomeSnapshot` / `BudgetSummary`.
struct FinancialInputs: Equatable {
    let periodTotal: Double
    let previousPeriodTotal: Double
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
        // Paliers de maturité des données
        if inputs.allTimeTicketCount == 0 {
            return FinancialState(kind: .welcome, tone: .neutral)
        }
        if inputs.allTimeTicketCount < 3 {
            return FinancialState(kind: .building, tone: .neutral)
        }

        // Pas de période précédente exploitable → état stable par défaut
        guard inputs.previousPeriodTotal > 0 else {
            return FinancialState(kind: .steady, tone: .neutral)
        }

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
