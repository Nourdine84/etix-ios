import SwiftUI
import CoreData

struct TicketDetailView: View {
    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    // ✅ Popup custom suppression
    @State private var showConfirmDeletePopup = false

    @State private var showEdit = false

    let ticket: Ticket

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {

                // Montant
                Text(String(format: "%.2f €", ticket.amount))
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color(Theme.primaryBlue))
                    .padding(.top, 18)

                detailRow(title: "Magasin", value: ticket.storeName)
                detailRow(title: "Catégorie", value: ticket.category)
                detailRow(title: "Date", value: formattedDate(ticket.dateMillis))

                if let desc = ticket.ticketDescription, !desc.isEmpty {
                    detailRow(title: "Description", value: desc)
                }

                // Modifier
                Button {
                    Haptic.light()
                    showEdit = true
                } label: {
                    Text("Modifier le ticket")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(Theme.primaryBlue))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }

                // Supprimer
                Button(role: .destructive) {
                    Haptic.medium()
                    showConfirmDeletePopup = true
                } label: {
                    Text("Supprimer")
                        .frame(maxWidth: .infinity)
                }
            }
            .padding()
        }
        .navigationTitle("Détail")
        .sheet(isPresented: $showEdit) {
            TicketEditView(ticket: ticket)
        }
        // ✅ Remplace l’alert système
        .overlay {
            if showConfirmDeletePopup {
                ConfirmDeletePopup {
                    // onConfirm
                    deleteTicket()
                    showConfirmDeletePopup = false
                } onCancel: {
                    // onCancel
                    showConfirmDeletePopup = false
                }
                .zIndex(10)
            }
        }
    }

    private func detailRow(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(value)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func deleteTicket() {
        context.delete(ticket)
        do {
            try context.save()
            Haptic.medium()
            dismiss()
        } catch {
            // Si tu veux : tu peux afficher un ErrorPopup ici aussi
            print("❌ Delete failed:", error)
        }
    }

    private func formattedDate(_ ms: Int64) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: Date(timeIntervalSince1970: Double(ms) / 1000))
    }
}
