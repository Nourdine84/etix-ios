import SwiftUI
import CoreData

struct TicketEditView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var store: String
    @State private var amount: String
    @State private var category: String
    @State private var date: Date
    @State private var description: String

    let ticket: Ticket

    init(ticket: Ticket) {
        self.ticket = ticket
        _store = State(initialValue: ticket.storeName)
        _amount = State(initialValue: String(ticket.amount))
        _category = State(initialValue: ticket.category)
        _description = State(initialValue: ticket.ticketDescription ?? "")
        _date = State(initialValue: Date(timeIntervalSince1970: TimeInterval(ticket.dateMillis) / 1000.0))
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Informations")) {
                    TextField("Magasin", text: $store)

                    TextField("Montant", text: $amount)
                        .keyboardType(.decimalPad)

                    TextField("Catégorie", text: $category)

                    DatePicker("Date",
                               selection: $date,
                               displayedComponents: .date)

                    TextField("Description",
                              text: $description,
                              axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Modifier")
            .toolbar {
                // Bouton Annuler
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Annuler") {
                        Haptic.light()
                        dismiss()
                    }
                }

                // Bouton Enregistrer
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Enregistrer") {
                        saveChanges()
                    }
                }
            }
        }
    }

    private func saveChanges() {
        guard let amountValue = Double(
            amount.replacingOccurrences(of: ",", with: ".")
        ) else {
            Haptic.error()
            return
        }

        ticket.storeName = store
        ticket.category = category
        ticket.amount = amountValue
        ticket.ticketDescription = description
        ticket.dateMillis = Int64(date.timeIntervalSince1970 * 1000)

        do {
            try context.save()
            Haptic.success()
        } catch {
            print("❌ Erreur sauvegarde :", error.localizedDescription)
            Haptic.error()
        }

        dismiss()
    }
}
