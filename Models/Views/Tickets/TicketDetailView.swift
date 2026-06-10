import SwiftUI
import CoreData

struct TicketDetailView: View {

    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var showConfirmDeletePopup = false
    @State private var showEdit = false

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
                    actions
                }
                .padding(.horizontal, 24)
                .padding(.top, 32)
                .padding(.bottom, 48)
            }
            .scrollIndicators(.hidden)
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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

    // MARK: - Actions

    private var actions: some View {
        VStack(spacing: 12) {
            Button {
                Haptic.light()
                showEdit = true
            } label: {
                Text("Modifier")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color(.secondarySystemGroupedBackground))
                    .foregroundColor(.primary)
                    .cornerRadius(20)
            }

            Button(role: .destructive) {
                Haptic.medium()
                showConfirmDeletePopup = true
            } label: {
                Text("Supprimer ce ticket")
                    .font(.footnote)
                    .foregroundColor(.red.opacity(0.8))
                    .padding(.vertical, 8)
            }
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
