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
    @State private var amountInvalid = false
    @State private var showCategoryPicker = false

    let ticket: Ticket

    init(ticket: Ticket) {
        self.ticket = ticket
        _store = State(initialValue: ticket.storeName)
        _amount = State(initialValue: String(format: "%.2f", ticket.amount))
        _category = State(initialValue: ticket.category)
        _description = State(initialValue: ticket.ticketDescription ?? "")
        _date = State(initialValue: Date(timeIntervalSince1970: TimeInterval(ticket.dateMillis) / 1000.0))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.Background.primary
                    .ignoresSafeArea()

                ScrollView {
                    TicketForm(
                        storeName: $store,
                        amount: $amount,
                        date: $date,
                        category: $category,
                        description: $description,
                        amountInvalid: amountInvalid,
                        onPickCategory: {
                            Haptic.light()
                            showCategoryPicker = true
                        }
                    )
                    .padding(.horizontal, Theme.Spacing.xxl)
                    .padding(.vertical, Theme.Spacing.l)
                }
                .scrollIndicators(.hidden)
                // Le montant redevient valide dès que l'utilisateur le corrige.
                .onChange(of: amount) { _, _ in amountInvalid = false }
            }
            .navigationTitle("Modifier")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCategoryPicker) {
                CategoryPickerSheet(selectedCategory: $category, context: context)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        Haptic.light()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        saveChanges()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Save

    private func saveChanges() {
        guard let amountValue = AmountParser.parse(amount) else {
            amountInvalid = true
            Haptic.error()
            return
        }

        ticket.storeName = store.trimmingCharacters(in: .whitespaces)
        ticket.category = category.trimmingCharacters(in: .whitespaces)
        ticket.amount = amountValue
        ticket.ticketDescription = description.isEmpty ? nil : description
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
