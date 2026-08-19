import SwiftUI
import CoreData

/// Ticket Detail V2 — mission : **« est-ce bien ce ticket, et que puis-je en faire ? »**.
///
/// Hero C (stub) : le montant est **libéré sur le fond**, rattaché juste dessous
/// à une **carte d'identité** ; les deux se lisent comme **un seul objet ticket**
/// (« total imprimé » + « corps du reçu »). Calme, précis, plus silencieux que
/// Home. 100 % Design System, aucune donnée inventée.
struct TicketDetailView: View {

    @Environment(\.managedObjectContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var scheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showConfirmDeletePopup = false
    @State private var showEdit = false
    @State private var showShare = false
    @State private var shareItems: [Any] = []
    @State private var noteExpanded = false

    /// Le montant scale avec Dynamic Type (garde-fou `minimumScaleFactor`,
    /// pas mécanisme principal). Base 40 pt, référence `largeTitle`.
    @ScaledMetric(relativeTo: .largeTitle) private var amountSize: CGFloat = 40

    let ticket: Ticket

    var body: some View {
        ZStack(alignment: .top) {
            Theme.Background.primary.ignoresSafeArea()
            if scheme == .dark { headerAmbient }

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.xl) {

                    // Stub : montant + carte, rattachés (écart serré).
                    VStack(alignment: .leading, spacing: Theme.Spacing.m) {
                        heroAmount
                        identityCard
                    }

                    noteSection
                }
                .padding(.horizontal, Theme.Spacing.xxl)
                .padding(.top, Theme.Spacing.xl)
                .padding(.bottom, Theme.Spacing.section)
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

    // MARK: - Hero (montant libéré, aligné sur la grille de la carte)

    private var heroAmount: some View {
        Text(formattedAmount)
            .font(.system(size: amountSize, weight: .heavy, design: .rounded))
            .foregroundColor(.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity, alignment: .leading)
            // Aligne le bord gauche du montant avec le contenu de la carte.
            .padding(.leading, Theme.Spacing.l)
            .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Carte d'identité

    private var identityCard: some View {
        VStack(spacing: 0) {
            HStack(spacing: Theme.Spacing.m) {
                storeMonogram
                VStack(alignment: .leading, spacing: 2) {
                    Text(ticket.storeName)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    Text(dateString)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer(minLength: 0)
            }

            Divider().padding(.vertical, Theme.Spacing.m)

            HStack(spacing: Theme.Spacing.m) {
                CategoryIconView(category: ticket.category, size: 40)
                Text(categoryLabel)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                Spacer(minLength: 0)
            }
        }
        .card(radius: Theme.Radius.l, padding: Theme.Spacing.l)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(formattedAmount), \(ticket.storeName), \(dateString), \(categoryLabel)")
    }

    /// Monogramme magasin — helper privé (promotion DS différée). Règle triviale :
    /// **première lettre utile + couleur stable** (hash FNV du nom). Aucun logo.
    private var storeMonogram: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(monogramColor(ticket.storeName))
            .frame(width: 40, height: 40)
            .overlay(
                Text(monogramLetter(ticket.storeName))
                    .font(.headline.weight(.bold))
                    .foregroundColor(.white)
            )
            .accessibilityHidden(true)
    }

    // MARK: - Note (hors carte, section secondaire sobre)

    @ViewBuilder
    private var noteSection: some View {
        if let note = ticket.ticketDescription?.trimmingCharacters(in: .whitespacesAndNewlines),
           !note.isEmpty {
            VStack(alignment: .leading, spacing: Theme.Spacing.s) {
                Text("NOTE")
                    .font(.caption.weight(.medium))
                    .tracking(1)
                    .foregroundColor(.secondary)

                Text(note)
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .lineLimit(noteExpanded ? nil : 4)
                    .fixedSize(horizontal: false, vertical: true)

                if note.count > 140 {
                    Button(noteExpanded ? "Voir moins" : "Voir plus") {
                        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                            noteExpanded.toggle()
                        }
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Theme.primaryBlue)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Ambiance Dark scopée header (helper privé, dark only)

    private var headerAmbient: some View {
        Canvas { ctx, size in
            var seed: UInt32 = 13
            func next() -> CGFloat {
                seed = seed &* 1_664_525 &+ 1_013_904_223
                return CGFloat(seed % 1000) / 1000
            }
            for _ in 0..<10 {
                let x = next() * size.width
                let y = next() * size.height
                let r = 0.5 + next() * 1.0
                let a = 0.05 + next() * 0.09
                ctx.fill(Path(ellipseIn: CGRect(x: x, y: y, width: r * 2, height: r * 2)),
                         with: .color(.white.opacity(a)))
            }
        }
        .frame(height: 170)
        .frame(maxWidth: .infinity, alignment: .top)
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    // MARK: - Actions (barre de navigation)

    /// Partager = **résumé texte** (intention « envoyer vite »), pas un PDF.
    private func sharePlainSummary() {
        Haptic.light()
        let parts = [ticket.storeName, formattedAmount, dateString, categoryLabel]
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
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

    // MARK: - Dérivés présentationnels

    private var categoryLabel: String {
        let c = ticket.category.trimmingCharacters(in: .whitespaces)
        return c.isEmpty ? "Sans catégorie" : c
    }

    private var dateString: String {
        DateUtils.shortString(fromMillis: ticket.dateMillis)
    }

    private static let currencyFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "EUR"
        f.locale = .current
        return f
    }()

    private var formattedAmount: String {
        Self.currencyFormatter.string(from: NSNumber(value: ticket.amount))
            ?? String(format: "%.2f €", ticket.amount)
    }

    private func monogramLetter(_ name: String) -> String {
        for ch in name where ch.isLetter || ch.isNumber {
            return String(ch).uppercased()
        }
        return "?"
    }

    private func monogramColor(_ name: String) -> Color {
        let palette: [Color] = [.blue, .green, .orange, .purple, .pink, .teal, .indigo, .mint, .red, .cyan]
        var hash: UInt32 = 2_166_136_261
        for byte in name.lowercased().utf8 {
            hash ^= UInt32(byte)
            hash = hash &* 16_777_619
        }
        return palette[Int(hash % UInt32(palette.count))]
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
