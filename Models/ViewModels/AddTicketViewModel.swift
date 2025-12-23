import Foundation
import CoreData

final class AddTicketViewModel: ObservableObject {

    // MARK: - Form fields
    @Published var storeName = ""
    @Published var amount = ""
    @Published var date = Date()
    @Published var category = ""
    @Published var description = ""

    // MARK: - Core Data
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    // MARK: - Public API
    @discardableResult
    func saveTicket() -> Bool {
        guard
            let amountValue = validatedAmount(),
            let store = validatedStore()
        else {
            return false
        }

        createTicket(
            store: store,
            amount: amountValue,
            date: date,
            category: category,
            description: description
        )

        do {
            try context.save()
            resetForm()
            return true
        } catch {
            print("❌ CoreData save error:", error.localizedDescription)
            return false
        }
    }

    // MARK: - Validation
    private func validatedAmount() -> Double? {
        Double(
            amount
                .replacingOccurrences(of: ",", with: ".")
                .trimmingCharacters(in: .whitespaces)
        )
    }

    private func validatedStore() -> String? {
        let trimmed = storeName.trimmingCharacters(in: .whitespaces)
        return trimmed.isEmpty ? nil : trimmed
    }

    // MARK: - Core Data
    private func createTicket(
        store: String,
        amount: Double,
        date: Date,
        category: String,
        description: String
    ) {
        let ticket = Ticket(context: context)

        // ✅ PAS DE ticket.id
        ticket.storeName = store
        ticket.amount = amount
        ticket.dateMillis = Int64(date.timeIntervalSince1970 * 1000)
        ticket.category = category.trimmingCharacters(in: .whitespaces)
        ticket.ticketDescription = description
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .isEmpty ? nil : description
    }

    // MARK: - Reset
    private func resetForm() {
        storeName = ""
        amount = ""
        date = Date()
        category = ""
        description = ""
    }
}
