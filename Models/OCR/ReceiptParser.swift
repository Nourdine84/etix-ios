import Foundation

/// Parse le texte brut d'un ticket (déjà reconnu par l'OCR) en données métier.
///
/// **Pur** : aucune dépendance à Vision, VisionKit ou UIKit. Il reçoit un texte,
/// il retourne un modèle — donc entièrement testable en isolation. La
/// reconnaissance de texte (Vision) reste, elle, dans le `OCRScannerView`.
///
/// Chaque champ est renvoyé avec un **niveau de confiance** (jamais un
/// pourcentage) selon l'heuristique qui a matché.
enum ReceiptParser {

    static func parse(_ text: String) -> OCRExtractedData {
        let lines = text.components(separatedBy: .newlines)
        let lowered = lines.map { $0.lowercased() }

        return OCRExtractedData(
            storeName: extractStore(from: lines),
            amount: extractAmount(from: lowered),
            date: extractDate(from: lowered)
        )
    }

    // MARK: - Montant

    private static let totalKeywords = ["total", "a payer", "à payer", "net", "montant ttc", "ttc"]

    /// Montant sur une ligne « TOTAL / TTC / À PAYER » → confiance **élevée**.
    /// Premier montant trouvé ailleurs → confiance **faible**.
    static func extractAmount(from loweredLines: [String]) -> OCRField<Double> {
        for line in loweredLines where totalKeywords.contains(where: { line.contains($0) }) {
            if let amount = amountIn(line) {
                return OCRField(value: amount, confidence: .high)
            }
        }
        for line in loweredLines {
            if let amount = amountIn(line) {
                return OCRField(value: amount, confidence: .low)
            }
        }
        return .missing
    }

    private static func amountIn(_ line: String) -> Double? {
        let regex = try! NSRegularExpression(pattern: #"(\d+[.,]\d{2})"#)
        guard let match = regex.matches(in: line, range: NSRange(line.startIndex..., in: line)).first,
              let range = Range(match.range, in: line) else { return nil }
        return Double(line[range].replacingOccurrences(of: ",", with: "."))
    }

    // MARK: - Magasin

    /// Première ligne plausible dans les 5 premières → confiance **moyenne**.
    /// Aucun repli : si aucune ligne plausible n'est trouvée, le magasin reste
    /// **non détecté** (`.missing`). Cela évite d'injecter un nom fantôme à
    /// partir de bruit OCR et permet à un résultat réellement vide de rester
    /// vide (écran « Aucune information détectée »).
    static func extractStore(from lines: [String]) -> OCRField<String> {
        for line in lines.prefix(5) {
            let t = line.trimmingCharacters(in: .whitespaces)
            guard t.count >= 3 else { continue }
            guard !t.allSatisfy({ $0.isNumber || " ./-".contains($0) }) else { continue }
            guard !isDateLike(t) else { continue }
            let lower = t.lowercased()
            guard !lower.hasPrefix("ticket") && !lower.hasPrefix("n°")
                    && !lower.hasPrefix("facture") && !lower.hasPrefix("recu") else { continue }
            return OCRField(value: t.capitalized, confidence: .medium)
        }
        return .missing
    }

    private static func isDateLike(_ s: String) -> Bool {
        let pattern = #"\d{2}[/\-\.]\d{2}[/\-\.]\d{2,4}"#
        return (try? NSRegularExpression(pattern: pattern))?
            .firstMatch(in: s, range: NSRange(s.startIndex..., in: s)) != nil
    }

    // MARK: - Date

    private static let dateFormats = ["dd/MM/yyyy", "dd-MM-yyyy", "dd.MM.yyyy", "dd/MM/yy", "dd-MM-yy"]

    /// Une ligne au format date reconnu → confiance **élevée**, sinon non détecté.
    static func extractDate(from lines: [String]) -> OCRField<Date> {
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            for format in dateFormats {
                let df = DateFormatter()
                df.locale = Locale(identifier: "fr_FR")
                df.dateFormat = format
                if let d = df.date(from: trimmed) {
                    return OCRField(value: d, confidence: .high)
                }
            }
        }
        return .missing
    }
}
