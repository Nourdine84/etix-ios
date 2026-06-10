import Foundation

/// Persistance des fenêtres de visibilité d'insights (UserDefaults.standard).
/// Sprint 1 : seul `unusualSpending` est concerné — visible 72h après sa première
/// apparition, puis supprimé jusqu'au mois calendaire suivant.
/// Les autres types ne sont jamais supprimés — aucune clé stockée pour eux.
enum InsightMemory {

    private static let visibilityWindows: [InsightType: TimeInterval] = [
        .unusualSpending: 72 * 3600
    ]

    private static func key(for type: InsightType) -> String {
        "insight.\(type.rawValue).firstShown"
    }

    static func isSuppressed(_ type: InsightType, now: Date = Date()) -> Bool {
        guard let window = visibilityWindows[type] else { return false }
        let firstShown = UserDefaults.standard.double(forKey: key(for: type))
        guard firstShown > 0 else { return false }

        let shownDate = Date(timeIntervalSince1970: firstShown)
        let sameMonth = Calendar.current.isDate(shownDate, equalTo: now, toGranularity: .month)
        guard sameMonth else { return false } // nouveau mois → ré-éligible

        return now.timeIntervalSince1970 - firstShown >= window
    }

    static func markShown(_ type: InsightType, now: Date = Date()) {
        guard visibilityWindows[type] != nil else { return }

        let existing = UserDefaults.standard.double(forKey: key(for: type))
        if existing > 0 {
            let shownDate = Date(timeIntervalSince1970: existing)
            // Ne pas rafraîchir le timestamp dans le même mois — la fenêtre
            // court depuis la PREMIÈRE apparition
            if Calendar.current.isDate(shownDate, equalTo: now, toGranularity: .month) {
                return
            }
        }
        UserDefaults.standard.set(now.timeIntervalSince1970, forKey: key(for: type))
    }
}
