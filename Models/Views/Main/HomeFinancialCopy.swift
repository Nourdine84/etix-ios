import Foundation

/// Copie éditoriale **Home** de l'état financier — **purement présentationnelle**.
///
/// Elle traduit un `FinancialState` (source de vérité) en une phrase Home ;
/// elle ne modifie jamais `kind`/`tone` et ne contient aucune logique métier.
/// Les autres surfaces (Widget, Watch, Notifications…) auront leur propre copie
/// du même état.
enum HomeFinancialCopy {

    /// Message d'une ligne pour le Hero. Le `range` n'adapte que le mot de
    /// période là où c'est naturel (« ce mois-ci » ↔ « aujourd'hui » / « cette année »).
    static func message(for state: FinancialState, range: TimeRange) -> String {
        switch state.kind {
        case .welcome:      return "Ajoute ton premier ticket"
        case .building:     return "Ton suivi prend forme"
        case .saving:       return "Tu dépenses moins que d'habitude"
        case .underControl: return "Belle maîtrise \(period(range))"
        case .steady:       return "Tes dépenses sont stables"
        case .slightRise:   return "Légère hausse \(period(range))"
        case .highSpending: return "Ton rythme de dépenses augmente"
        }
    }

    private static func period(_ range: TimeRange) -> String {
        switch range {
        case .today: return "aujourd'hui"
        case .month: return "ce mois-ci"
        case .year:  return "cette année"
        }
    }
}
