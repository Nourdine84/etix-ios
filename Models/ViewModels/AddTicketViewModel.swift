import Foundation
import SwiftUI
import CoreData

final class AddTicketViewModel: ObservableObject {

    @Published var storeName: String = ""
    @Published var amount: String = ""
    @Published var date: Date = Date()
    @Published var category: TicketCategory = .other
    @Published var description: String = ""

    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    @discardableResult
    func saveTicket() -> Bool {
        guard
            let amountValue = Double(amount),
            !storeName.trimmingCharacters(in: .whitespaces).isEmpty
        else { return false }

        let dateMillis = Int64(date.timeIntervalSince1970 * 1000)

        Ticket.create(
            storeName: storeName.trimmingCharacters(in: .whitespaces),
            amount: amountValue,
            dateMillis: dateMillis,
            category: category.rawValue,
            description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                ? nil
                : description,
            in: context
        )

        do {
            try context.save()
            resetForm()
            return true
        } catch {
            print("❌ Save error:", error)
            return false
        }
    }

    func resetForm() {
        storeName = ""
        amount = ""
        date = Date()
        category = .other
        description = ""
    }
}
