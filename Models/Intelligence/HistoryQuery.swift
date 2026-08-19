import Foundation

/// Tri exposé à l'utilisateur en History V2 (périmètre validé — pas de tri
/// magasin pour l'instant).
enum HistorySort: CaseIterable, Equatable {
    case recentFirst
    case oldestFirst
    case amountDesc
    case amountAsc
}

/// Saisie utilisateur d'History — **seule source de la requête**.
///
/// Deux modèles mentaux :
/// - `text` répond à « de quoi je me souviens ? » (recherche libre).
/// - les filtres (`period`, `amount`, `categories`, `stores`) répondent à
///   « comment je réduis le résultat ? ».
///
/// `sort` n'est pas un filtre : il **n'affecte pas** `isNarrowed`.
struct HistoryQuery: Equatable {

    var text: String = ""

    var startDate: Date? = nil
    var endDate: Date? = nil

    var minAmount: Double? = nil
    var maxAmount: Double? = nil

    var categories: Set<String> = []
    var stores: Set<String> = []

    var sort: HistorySort = .recentFirst

    /// Vrai dès qu'une recherche **ou** un filtre restreint le résultat.
    /// Le tri seul ne « restreint » pas → exclu.
    var isNarrowed: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || startDate != nil
            || endDate != nil
            || minAmount != nil
            || maxAmount != nil
            || !categories.isEmpty
            || !stores.isEmpty
    }
}
