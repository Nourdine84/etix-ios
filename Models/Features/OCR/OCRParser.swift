import Foundation

enum OCRParser {

    static func parse(lines: [String]) -> OCRExtractedData {

        let cleanedLines = lines
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var storeName: String?
        var amount: Double?
        var date: Date?
        var confidence: Double = 0.0

        // 💰 Montant (priorité TOTAL)
        if let extractedAmount = extractAmount(from: cleanedLines) {
            amount = extractedAmount
            confidence += 0.4
        }

        // 📅 Date
        if let extractedDate = extractDate(from: cleanedLines) {
            date = extractedDate
            confidence += 0.3
        }

        // 🏪 Magasin
        if let extractedStore = extractStoreName(from: cleanedLines) {
            storeName = extractedStore
            confidence += 0.3
        }

        confidence = min(confidence, 1.0)

        return OCRExtractedData(
            storeName: storeName,
            amount: amount,
            date: date,
            confidence: confidence
        )
    }

    // MARK: - Amount
    private static func extractAmount(from lines: [String]) -> Double? {

        let amountRegex = #"(\d+[,.]\d{2})\s?€?"#

        // 1️⃣ Ligne contenant TOTAL
        for line in lines {
            if line.lowercased().contains("total"),
               let match = line.range(of: amountRegex, options: .regularExpression) {
                return normalizeAmount(String(line[match]))
            }
        }

        // 2️⃣ Plus gros montant détecté
        let amounts = lines.compactMap { line -> Double? in
            guard let match = line.range(of: amountRegex, options: .regularExpression) else { return nil }
            return normalizeAmount(String(line[match]))
        }

        return amounts.max()
    }

    private static func normalizeAmount(_ raw: String) -> Double? {
        let value = raw
            .replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: ",", with: ".")
        return Double(value)
    }

    // MARK: - Date
    private static func extractDate(from lines: [String]) -> Date? {

        let formats = [
            "dd/MM/yyyy",
            "dd-MM-yyyy",
            "dd.MM.yyyy",
            "dd/MM/yy",
            "dd-MM-yy"
        ]

        for line in lines {
            for format in formats {
                let df = DateFormatter()
                df.locale = Locale(identifier: "fr_FR")
                df.dateFormat = format

                // 🔎 détecte même si la date est dans une phrase
                if let range = line.range(of: #"\d{2}([\/\-.])\d{2}\1\d{2,4}"#, options: .regularExpression) {
                    let candidate = String(line[range])
                    if let date = df.date(from: candidate) {
                        return date
                    }
                }
            }
        }
        return nil
    }

    // MARK: - Store
    private static func extractStoreName(from lines: [String]) -> String? {

        let blacklist = [
            "total",
            "tva",
            "merci",
            "ticket",
            "client",
            "carte",
            "cb",
            "paiement"
        ]

        for line in lines.prefix(6) {
            let lower = line.lowercased()

            if blacklist.contains(where: { lower.contains($0) }) { continue }
            if line.count < 3 { continue }
            if line.range(of: #"\d"#, options: .regularExpression) != nil { continue }

            return line.capitalized
        }

        return nil
    }
}
