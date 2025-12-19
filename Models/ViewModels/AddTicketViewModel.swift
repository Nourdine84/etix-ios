import Foundation
import SwiftUI
import CoreData

class AddTicketViewModel: ObservableObject {
    @Published var storeName: String = ""
    @Published var amount: String = ""
    @Published var date: Date = Date()
    @Published var category: String = ""
    @Published var description: String = ""

    let context: NSManagedObjectContext   // ⬅️ rendu public pour WidgetSync

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    /// Enregistre un ticket + sauvegarde Core Data
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
            try context.save()       // ⬅️ CRUCIAL POUR LE WIDGET
        } catch {
            print("❌ Save error:", error.localizedDescription)
            return false
        }

        resetForm()
        return true
    }

    func resetForm() {
        storeName = ""
        amount = ""
        date = Date()
        category = ""
        description = ""
    }
}
