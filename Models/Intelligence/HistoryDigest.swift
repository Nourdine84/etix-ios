import Foundation

/// Contrat de données minimal qu'un ticket doit fournir au moteur History.
/// Rend `HistoryDigest` **pur et testable sans CoreData** : `Ticket` s'y
/// conforme en production, un mock léger s'y conforme en test.
protocol HistoryTicketData {
    var storeName: String { get }
    var amount: Double { get }
    var dateMillis: Int64 { get }
    var category: String { get }
    var ticketDescription: String? { get }
}

extension Ticket: HistoryTicketData {}

/// Une rangée du digest : le ticket + un éventuel extrait expliquant un match
/// sur la description OCR (`nil` en navigation normale).
struct HistoryRow<T: HistoryTicketData & Identifiable>: Identifiable {
    let item: T
    let snippet: String?
    var id: T.ID { item.id }
}

/// Une section = un **jour** (structure prévisible quelle que soit la
/// volumétrie), avec son total journalier.
struct HistorySection<T: HistoryTicketData & Identifiable>: Identifiable {
    /// Clé stable du jour (`yyyy-MM-dd`), utilisée aussi comme `id`.
    let id: String
    let label: String
    let date: Date
    let dayTotal: Double
    let rows: [HistoryRow<T>]
}

/// Résultat immuable dérivé d'une `HistoryQuery` sur un lot de tickets.
struct HistoryDigest<T: HistoryTicketData & Identifiable> {
    let sections: [HistorySection<T>]
    let resultCount: Int
    let resultTotal: Double
    /// Recherche ou filtre actif (pilote l'affichage du ResultMeter et le
    /// masquage des totaux journaliers en mode recherche).
    let isNarrowed: Bool

    static var empty: HistoryDigest {
        HistoryDigest(sections: [], resultCount: 0, resultTotal: 0, isNarrowed: false)
    }
}

/// Moteur de dérivation History — **pur, sans UI, sans état stocké**.
///
/// Construit **une fois par render** (comme `HomeSnapshot`), aucune
/// mémoïsation, aucune source de vérité supplémentaire.
///
/// ## Complexité (N = lot brut, M = sous-ensemble retenu ≤ N)
/// - **Filtrage + accumulation** (count/total, snippets) : **O(N)**.
/// - **Tri du sous-ensemble** :
///   - `.recentFirst` : **O(1)** — on réutilise l'ordre déjà fourni par le
///     `FetchRequest` (date décroissante). Aucun tri.
///   - `.oldestFirst` : **O(M)** — simple inversion.
///   - `.amountDesc` / `.amountAsc` : **O(M log M)**.
/// - **Regroupement par jour** : **O(M)**.
///
/// ## Ordonnancement
/// Le tri ordonne les **rangées** ; les **sections** apparaissent dans l'ordre
/// de **première rencontre** d'un jour sous le tri actif (chronologique pour
/// les tris temporels ; pilotée par les montants pour les tris montant). Les
/// rangées d'un même jour suivent le tri. Structure toujours par jour.
enum HistoryDigestEngine {

    static func build<T: HistoryTicketData & Identifiable>(
        tickets: [T],
        query: HistoryQuery,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> HistoryDigest<T> {

        let needle = query.text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        let startBound: Int64? = query.startDate.map {
            Int64(calendar.startOfDay(for: $0).timeIntervalSince1970 * 1000)
        }
        let endBound: Int64? = query.endDate.map {
            let dayAfter = calendar.date(
                byAdding: .day, value: 1,
                to: calendar.startOfDay(for: $0)
            )!
            return Int64(dayAfter.timeIntervalSince1970 * 1000)
        }

        // 1. Filtrage + accumulation — O(N). Ordre d'entrée préservé (date desc).
        var matched: [HistoryRow<T>] = []
        var total: Double = 0

        for ticket in tickets {
            var descriptionMatched = false

            if !needle.isEmpty {
                let inStore = ticket.storeName.lowercased().contains(needle)
                let inCategory = ticket.category.lowercased().contains(needle)
                descriptionMatched = ticket.ticketDescription?
                    .lowercased().contains(needle) ?? false
                guard inStore || inCategory || descriptionMatched else { continue }
            }

            if let startBound, ticket.dateMillis < startBound { continue }
            if let endBound, ticket.dateMillis >= endBound { continue }
            if let min = query.minAmount, ticket.amount < min { continue }
            if let max = query.maxAmount, ticket.amount > max { continue }
            if !query.categories.isEmpty, !query.categories.contains(ticket.category) { continue }
            if !query.stores.isEmpty, !query.stores.contains(ticket.storeName) { continue }

            let snippet = descriptionMatched
                ? snippet(from: ticket.ticketDescription, matching: needle)
                : nil

            matched.append(HistoryRow(item: ticket, snippet: snippet))
            total += ticket.amount
        }

        // 2. Tri du sous-ensemble.
        let ordered: [HistoryRow<T>]
        switch query.sort {
        case .recentFirst: ordered = matched                    // O(1) — ordre du fetch
        case .oldestFirst: ordered = matched.reversed()         // O(M)
        case .amountDesc:  ordered = matched.sorted { $0.item.amount > $1.item.amount }
        case .amountAsc:   ordered = matched.sorted { $0.item.amount < $1.item.amount }
        }

        // 3. Regroupement par jour — O(M), ordre de première rencontre.
        let keyFormatter = Self.keyFormatter
        let labelFormatter = Self.labelFormatter
        let today = calendar.startOfDay(for: now)
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)

        var order: [String] = []
        var byKey: [String: (label: String, date: Date, total: Double, rows: [HistoryRow<T>])] = [:]

        for row in ordered {
            let day = calendar.startOfDay(for: Date(timeIntervalSince1970: TimeInterval(row.item.dateMillis) / 1000))
            let key = keyFormatter.string(from: day)

            if byKey[key] == nil {
                let label: String
                if calendar.isDate(day, inSameDayAs: today) {
                    label = "Aujourd'hui"
                } else if let yesterday, calendar.isDate(day, inSameDayAs: yesterday) {
                    label = "Hier"
                } else {
                    label = labelFormatter.string(from: day)
                }
                byKey[key] = (label, day, 0, [])
                order.append(key)
            }
            byKey[key]!.total += row.item.amount
            byKey[key]!.rows.append(row)
        }

        let sections = order.map { key -> HistorySection<T> in
            let bucket = byKey[key]!
            return HistorySection(
                id: key,
                label: bucket.label,
                date: bucket.date,
                dayTotal: bucket.total,
                rows: bucket.rows
            )
        }

        return HistoryDigest(
            sections: sections,
            resultCount: matched.count,
            resultTotal: total,
            isNarrowed: query.isNarrowed
        )
    }

    // MARK: - Snippet OCR

    /// Fenêtre d'environ 20 caractères autour du terme trouvé dans la
    /// description, bordée de « … » quand elle est tronquée.
    private static func snippet(from description: String?, matching needle: String) -> String? {
        guard let description,
              let range = description.range(of: needle, options: .caseInsensitive)
        else { return nil }

        let lower = description.index(range.lowerBound, offsetBy: -20, limitedBy: description.startIndex) ?? description.startIndex
        let upper = description.index(range.upperBound, offsetBy: 20, limitedBy: description.endIndex) ?? description.endIndex

        var text = String(description[lower..<upper]).trimmingCharacters(in: .whitespacesAndNewlines)
        if lower > description.startIndex { text = "… " + text }
        if upper < description.endIndex { text += " …" }
        return text
    }

    // MARK: - Formatters

    private static let keyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static let labelFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.setLocalizedDateFormatFromTemplate("d MMM yyyy")
        return formatter
    }()
}
