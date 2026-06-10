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
            Form {
                Section("Informations") {
                    HStack(spacing: 12) {
                        Image(systemName: "storefront")
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                        TextField("Magasin", text: $store)
                    }

                    HStack(spacing: 12) {
                        Image(systemName: "eurosign.circle")
                            .foregroundColor(.secondary)
                            .frame(width: 20)
                        TextField("Montant", text: $amount)
                            .keyboardType(.decimalPad)
                            .foregroundColor(amountInvalid ? .red : .primary)
                            .onChange(of: amount) { _, _ in amountInvalid = false }
                    }

                    Button {
                        showCategoryPicker = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "tag")
                                .foregroundColor(.secondary)
                                .frame(width: 20)
                            Text(category.isEmpty ? "Catégorie" : category)
                                .foregroundColor(category.isEmpty ? Color(.placeholderText) : .primary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(.plain)

                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }

                Section("Note") {
                    TextField("Description (optionnel)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
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
        let normalized = amount.replacingOccurrences(of: ",", with: ".")
        guard let amountValue = Double(normalized), amountValue > 0 else {
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
