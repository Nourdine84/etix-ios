import Foundation

/// Persistance des fenêtres de visibilité d'insights (UserDefaults.standard).
///
/// Chaque type concerné possède une politique : une fenêtre de visibilité après
/// la première apparition, puis une suppression jusqu'à réinitialisation.
/// Deux modes de réinitialisation :
///  - `.nextCalendarMonth` : ré-éligible au changement de mois calendaire
///  - `.after(t)` : ré-éligible t secondes après la première apparition (glissant)
///
/// Sprint 1 : unusualSpending (72h, mensuel).
/// Sprint 4 : goodMonth & budgetsHealthy (1 fois par mois — visibles 24h puis
/// supprimés jusqu'au mois suivant), captureReminder (max 1 fois toutes les 48h —
/// visible 24h puis supprimé jusqu'à 48h après la première apparition).
/// Les autres types ne sont jamais supprimés — aucune clé stockée pour eux.
enum InsightMemory {

    private enum Reset {
        case nextCalendarMonth
        case after(TimeInterval)
    }

    private struct Policy {
        let visibleWindow: TimeInterval
        let reset: Reset
    }

    private static let policies: [InsightType: Policy] = [
        .unusualSpending: Policy(visibleWindow: 72 * 3600, reset: .nextCalendarMonth),
        .goodMonth:       Policy(visibleWindow: 24 * 3600, reset: .nextCalendarMonth),
        .budgetsHealthy:  Policy(visibleWindow: 24 * 3600, reset: .nextCalendarMonth),
        .captureReminder: Policy(visibleWindow: 24 * 3600, reset: .after(48 * 3600))
    ]

    private static func key(for type: InsightType) -> String {
        "insight.\(type.rawValue).firstShown"
    }

    static func isSuppressed(_ type: InsightType, now: Date = Date()) -> Bool {
        guard let policy = policies[type] else { return false }
        let firstShown = UserDefaults.standard.double(forKey: key(for: type))
        guard firstShown > 0 else { return false }

        let elapsed = now.timeIntervalSince1970 - firstShown
        guard elapsed >= policy.visibleWindow else { return false } // encore visible

        switch policy.reset {
        case .nextCalendarMonth:
            // Supprimé tant qu'on reste dans le mois de la première apparition
            let shownDate = Date(timeIntervalSince1970: firstShown)
            return Calendar.current.isDate(shownDate, equalTo: now, toGranularity: .month)
        case .after(let cooldown):
            return elapsed < cooldown
        }
    }

    static func markShown(_ type: InsightType, now: Date = Date()) {
        guard let policy = policies[type] else { return }

        let existing = UserDefaults.standard.double(forKey: key(for: type))
        if existing > 0 {
            // Ne pas rafraîchir le timestamp tant que la période de référence
            // court — la fenêtre démarre à la PREMIÈRE apparition
            switch policy.reset {
            case .nextCalendarMonth:
                let shownDate = Date(timeIntervalSince1970: existing)
                if Calendar.current.isDate(shownDate, equalTo: now, toGranularity: .month) {
                    return
                }
            case .after(let cooldown):
                if now.timeIntervalSince1970 - existing < cooldown {
                    return
                }
            }
        }
        UserDefaults.standard.set(now.timeIntervalSince1970, forKey: key(for: type))
    }
}
