import Foundation

/// Niveau de confiance d'un champ extrait par OCR, exprimé en **paliers**
/// (jamais en pourcentage : cela suggérerait une précision illusoire).
///
/// Correspondance d'affichage prévue côté UI (étape 3) :
/// `.high` → « Vérifié », `.medium`/`.low` → « À vérifier », `.none` → « Non détecté ».
enum OCRConfidence {
    case high
    case medium
    case low
    case none
}

/// Un champ extrait par l'OCR + sa confiance.
/// Invariant : `value == nil` ⇒ `confidence == .none`.
struct OCRField<Value> {
    let value: Value?
    let confidence: OCRConfidence

    init(value: Value?, confidence: OCRConfidence) {
        if value == nil {
            self.value = nil
            self.confidence = .none
        } else {
            self.value = value
            self.confidence = confidence
        }
    }

    /// Champ absent (non détecté).
    static var missing: OCRField { OCRField(value: nil, confidence: .none) }
}

/// Résultat métier d'un scan de ticket — **indépendant de Vision et d'UIKit**.
/// Produit par `ReceiptParser`, consommé par `AddTicketViewModel`.
struct OCRExtractedData {
    let storeName: OCRField<String>
    let amount: OCRField<Double>
    let date: OCRField<Date>
}
