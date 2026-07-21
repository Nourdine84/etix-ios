import Foundation

/// Normalisation et validation d'un montant saisi ou extrait — **pur, testable**.
///
/// Accepte la virgule décimale française (« 12,50 » → 12.50) et n'accepte qu'un
/// montant strictement positif. Destiné à être partagé par la saisie manuelle
/// (AddTicket) et l'édition (TicketEdit) — étape 3.
enum AmountParser {

    /// Retourne le montant si la saisie représente un nombre > 0, sinon `nil`.
    static func parse(_ raw: String) -> Double? {
        let normalized = raw
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: ",", with: ".")
        guard let value = Double(normalized), value > 0 else { return nil }
        return value
    }
}
