import Foundation
import SwiftUI
import CoreData

class AddTicketViewModel: ObservableObject {
    @Published var storeName: String = ""
    @Published var amount: String = ""
    @Published var date: Date = Date()
    @Published var category: String = ""
    @Published var description: String = ""
    @Published var ocrCategorySuggestion: CategoryConfidence? = nil

    // Confiance OCR par champ (couche métier) — mappée en FieldConfidence côté vue.
    @Published var storeConfidence: OCRConfidence = .none
    @Published var amountConfidence: OCRConfidence = .none
    @Published var dateConfidence: OCRConfidence = .none

    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    @discardableResult
    func saveTicket() -> Bool {
        guard let amountValue = AmountParser.parse(amount),
              !storeName.trimmingCharacters(in: .whitespaces).isEmpty else {
            return false
        }

        let dateMillis: Int64 = Int64(date.timeIntervalSince1970 * 1000)

        Ticket.create(
            storeName: storeName.trimmingCharacters(in: .whitespaces),
            amount: amountValue,
            dateMillis: dateMillis,
            category: category.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description,
            in: context
        )

        do {
            try context.save()
        } catch {
            print("❌ Save error:", error.localizedDescription)
            return false
        }

        resetForm()
        return true
    }

    func handleOCRResult(_ result: OCRExtractedData) {
        if let store = result.storeName.value {
            storeName = store
            storeConfidence = result.storeName.confidence
            if category.isEmpty {
                if let suggestion = StoreCategoryMapper.suggest(for: store, context: context) {
                    category = suggestion.category
                    // strongHistory = trusted enough to fill silently, no badge
                    ocrCategorySuggestion = suggestion.confidence == .strongHistory
                        ? nil
                        : suggestion.confidence
                }
            }
        }
        if let amt = result.amount.value {
            amount = String(format: "%.2f", amt)
            amountConfidence = result.amount.confidence
        }
        if let d = result.date.value {
            date = d
            dateConfidence = result.date.confidence
        }
    }

    func resetForm() {
        storeName = ""
        amount = ""
        date = Date()
        category = ""
        description = ""
        ocrCategorySuggestion = nil
        storeConfidence = .none
        amountConfidence = .none
        dateConfidence = .none
    }
}

// MARK: - Mapping confiance OCR → affichage

/// Traduit la confiance métier (`OCRConfidence`) en badge d'affichage
/// (`FieldConfidence`). Vit côté Add (couche qui connaît l'OCR) afin que
/// `TicketForm` reste totalement agnostique. `.none` ⇒ aucun badge.
extension FieldConfidence {
    init?(ocr: OCRConfidence) {
        switch ocr {
        case .high:            self = .verified
        case .medium, .low:    self = .toVerify
        case .none:            return nil
        }
    }
}
