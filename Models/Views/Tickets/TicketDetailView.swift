import SwiftUI
import CoreData

struct TicketDetailView: View {

    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var showConfirmDeletePopup = false
    @State private var showEdit = false
    @State private var showShare = false
    @State private var shareItems: [Any] = []

    let ticket: Ticket

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 32) {
                    heroAmount
                    dateCard
                    infoGrid
                    if let desc = ticket.ticketDescription, !desc.isEmpty {
                        descriptionCard(desc)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 48)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("Détail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Modifier") {
                    Haptic.light()
                    showEdit = true
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        sharePlainSummary()
                    } label: {
                        Label("Partager", systemImage: "square.and.arrow.up")
                    }
                    Button {
                        exportPDF()
                    } label: {
                        Label("Exporter en PDF", systemImage: "doc.richtext")
                    }
                    Divider()
                    Button(role: .destructive) {
                        Haptic.medium()
                        showConfirmDeletePopup = true
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("Plus d'actions")
            }
        }
        .sheet(isPresented: $showEdit) {
            TicketEditView(ticket: ticket)
        }
        .sheet(isPresented: $showShare) {
            ShareSheet(items: shareItems)
        }
        .overlay {
            if showConfirmDeletePopup {
                ConfirmDeletePopup {
                    deleteTicket()
                    showConfirmDeletePopup = false
                } onCancel: {
                    showConfirmDeletePopup = false
                }
                .zIndex(10)
            }
        }
    }

    // MARK: - Hero

    private var heroAmount: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MONTANT")
                .font(.caption)
                .tracking(1.5)
                .foregroundColor(.secondary)
            Text(String(format: "%.2f €", ticket.amount))
                .font(.system(size: 56, weight: .heavy, design: .rounded))
                .kerning(-1.5)
                .foregroundStyle(
                    LinearGradient(
                        colors: [Theme.primaryBlue, Theme.primaryBlue.opacity(0.75)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(ticket.storeName)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Date Card

    private var dateCard: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 2) {
                Text(formattedDay)
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundColor(.primary)
                Text(formattedMonthYear)
                    .font(.footnote.weight(.medium))
                    .foregroundColor(.secondary)
            }
            Divider().frame(height: 44)
            VStack(alignment: .leading, spacing: 4) {
                Text("DATE D'ACHAT")
                    .font(.caption2)
                    .tracking(1)
                    .foregroundColor(.secondary)
                Text(formattedWeekday)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.primary)
            }
            Spacer()
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }

    // MARK: - Info Grid

    private var infoGrid: some View {
        HStack(spacing: 16) {
            infoCard(icon: "storefront", label: "MAGASIN", value: ticket.storeName)
            infoCard(icon: "tag.fill", label: "CATÉGORIE", value: ticket.category)
        }
    }

    private func infoCard(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(label)
                    .font(.caption2)
                    .tracking(1)
                    .foregroundColor(.secondary)
            }
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }

    // MARK: - Description

    private func descriptionCard(_ desc: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "text.alignleft")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("NOTE")
                    .font(.caption2)
                    .tracking(1)
                    .foregroundColor(.secondary)
            }
            Text(desc)
                .font(.body)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
    }

    // MARK: - Actions (barre de navigation)

    /// Partager = **résumé texte** (intention « envoyer vite »), pas un PDF.
    private func sharePlainSummary() {
        Haptic.light()
        let parts = [
            ticket.storeName,
            String(format: "%.2f €", ticket.amount),
            formattedWeekday + " " + formattedDay + " " + formattedMonthYear,
            ticket.category
        ].filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        shareItems = [parts.joined(separator: " — ")]
        showShare = true
    }

    /// Exporter = **PDF** (intention « document »), via le service partagé.
    private func exportPDF() {
        Haptic.light()
        do {
            let data = try PDFExportService.exportTicket(ticket)
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent("ticket-\(ticket.id).pdf")
            try data.write(to: url, options: .atomic)
            shareItems = [url]
            showShare = true
        } catch {
            print("❌ PDF export failed:", error)
        }
    }

    // MARK: - Helpers

    private var ticketDate: Date {
        Date(timeIntervalSince1970: Double(ticket.dateMillis) / 1000)
    }

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd"
        return f
    }()

    private static let monthYearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.dateFormat = "MMMM yyyy"
        return f
    }()

    private static let weekdayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "fr_FR")
        f.dateFormat = "EEEE"
        return f
    }()

    private var formattedDay: String {
        Self.dayFormatter.string(from: ticketDate)
    }

    private var formattedMonthYear: String {
        Self.monthYearFormatter.string(from: ticketDate).capitalized
    }

    private var formattedWeekday: String {
        Self.weekdayFormatter.string(from: ticketDate).capitalized
    }

    private func deleteTicket() {
        context.delete(ticket)
        do {
            try context.save()
            Haptic.medium()
            dismiss()
        } catch {
            print("❌ Delete failed:", error)
        }
    }
}
