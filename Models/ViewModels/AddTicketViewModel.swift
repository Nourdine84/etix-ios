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

    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    @discardableResult
    func saveTicket() -> Bool {
        guard let amountValue = Double(amount),
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
        }
        if let d = result.date.value {
            date = d
        }
    }

    func resetForm() {
        storeName = ""
        amount = ""
        date = Date()
        category = ""
        description = ""
        ocrCategorySuggestion = nil
    }
}
