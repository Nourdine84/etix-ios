import SwiftUI
import CoreData

struct TicketDetailView: View {

    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var showConfirmDeletePopup = false
    @State private var showEdit = false

    let ticket: Ticket

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {

                amountSection
                    .premiumAppear()

                detailSection
                    .premiumAppear()

                actionButtons
                    .premiumAppear()
            }
            .padding(.horizontal, DesignSystem.horizontalPadding)
            .padding(.vertical, 40)
        }
        .navigationTitle("Détail")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showEdit) {
            TicketEditView(ticket: ticket)
        }
        .overlay {
            if showConfirmDeletePopup {
                ConfirmDeletePopup {
                    deleteTicket()
                    showConfirmDeletePopup = false
                } onCancel: {
                    showConfirmDeletePopup = false
                }
            }
        }
    }

    private var amountSection: some View {
        Text(String(format: "%.2f €", ticket.amount))
            .font(.system(size: 42, weight: .bold))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Theme.primaryBlue,
                        Theme.primaryBlue.opacity(0.85)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var detailSection: some View {
        VStack(spacing: 16) {
            detailRow("Magasin", ticket.storeName)
            detailRow("Catégorie", ticket.category)
            detailRow("Date", formattedDate(ticket.dateMillis))

            if let desc = ticket.ticketDescription, !desc.isEmpty {
                detailRow("Description", desc)
            }
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 14) {

            Button {
                showEdit = true
            } label: {
                Text("Modifier le ticket")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.primaryBlue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
            }

            Button(role: .destructive) {
                showConfirmDeletePopup = true
            } label: {
                Text("Supprimer")
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private func detailRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            Text(value)
                .font(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.mediumRadius)
                .fill(DesignSystem.surfaceSecondary)
        )
    }

    private func deleteTicket() {
        context.delete(ticket)
        try? context.save()
        dismiss()
    }

    private func formattedDate(_ ms: Int64) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: Date(timeIntervalSince1970: Double(ms) / 1000))
    }
}
