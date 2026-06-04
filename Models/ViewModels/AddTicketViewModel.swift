import Foundation
import SwiftUI
import CoreData

final class AddTicketViewModel: ObservableObject {

    @Published var storeName: String = ""
    @Published var amount: String = ""
    @Published var date: Date = Date()
    @Published var category: String = "Alimentation"
    @Published var description: String = ""

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

        let ticket = Ticket(context: context)
        ticket.id = Int64(Date().timeIntervalSince1970 * 1000)
        ticket.storeName = storeName.trimmingCharacters(in: .whitespaces)
        ticket.amount = amountValue
        ticket.category = category
        ticket.dateMillis = Int64(date.timeIntervalSince1970 * 1000)
        ticket.ticketDescription = description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? nil
            : description

        do {
            try context.save()
            resetForm()
            return true
        } catch {
            print("❌ Save error:", error.localizedDescription)
            return false
        }
    }

    func resetForm() {
        storeName = ""
        amount = ""
        date = Date()
        category = "Alimentation"
        description = ""
    }
}
