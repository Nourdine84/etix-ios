import SwiftUI

/// Rangée ticket standard du Design System V2 — **conçue pour trois
/// consommateurs** : History, CategoryDetail, StoreDetail. Elle unifie les
/// implémentations `ticketRow(_:)` divergentes de ces écrans.
///
/// Anatomie (mission « où est mon ticket ? ») :
/// `[ icône catégorie ] — magasin (dominant) / date·heure·catégorie (secondaire) — montant (trailing sobre)`
///
/// - Le magasin est la clé de reconnaissance visuelle n°1.
/// - Le montant est lisible mais **ne crie pas plus fort** que le magasin
///   (sobre, sans dégradé décoratif).
/// - `matchedSnippet` n'apparaît **que** lorsqu'une recherche a matché la
///   description/OCR : une 3ᵉ ligne qui **explique le match**, jamais du bruit.
/// - **Aucun slot statut** (Remboursé/Archive n'existent pas dans les données).
///
/// Dynamic Type : styles de texte dynamiques (`.headline` / `.subheadline` /
/// `.caption`) — la rangée scale avec les réglages d'accessibilité.
struct TicketRow: View {

    let ticket: Ticket

    /// Extrait de `ticketDescription` à afficher **uniquement** quand c'est lui
    /// qui a matché la recherche. `nil` en navigation normale.
    var matchedSnippet: String? = nil

    var body: some View {
        HStack(spacing: Theme.Spacing.m) {

            CategoryIconView(category: ticket.category, size: 40)

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(ticket.storeName)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Text(secondaryText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                if let snippet = trimmedSnippet {
                    Text(snippet)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }

            Spacer(minLength: Theme.Spacing.s)

            Text(amountText)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .card(radius: Theme.Radius.l, padding: Theme.Spacing.l)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityText)
    }

    // MARK: - Dérivés présentationnels

    private var amountText: String {
        String(format: "%.2f €", ticket.amount)
    }

    /// Date · heure · catégorie (catégorie omise si vide).
    private var secondaryText: String {
        let date = DateUtils.date(fromMillis: ticket.dateMillis)
        var parts = [
            DateUtils.shortString(fromMillis: ticket.dateMillis),
            Self.timeFormatter.string(from: date)
        ]
        let category = ticket.category.trimmingCharacters(in: .whitespaces)
        if !category.isEmpty { parts.append(category) }
        return parts.joined(separator: " · ")
    }

    private var trimmedSnippet: String? {
        guard let snippet = matchedSnippet?.trimmingCharacters(in: .whitespacesAndNewlines),
              !snippet.isEmpty else { return nil }
        return snippet
    }

    /// Label VoiceOver combiné : la rangée est **un seul élément**.
    private var accessibilityText: String {
        var text = "\(ticket.storeName), \(amountText), \(secondaryText)"
        if let snippet = trimmedSnippet { text += ", \(snippet)" }
        return text
    }

    private static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}

// MARK: - Previews

#Preview("Light") {
    previewList
        .padding(Theme.Spacing.xxl)
        .background(Theme.Background.primary)
}

#Preview("Dark") {
    previewList
        .padding(Theme.Spacing.xxl)
        .background(Theme.Background.primary)
        .preferredColorScheme(.dark)
}

@MainActor private var previewList: some View {
    let context = PersistenceController.shared.container.viewContext
    func make(_ store: String, _ amount: Double, _ category: String) -> Ticket {
        let ticket = Ticket(context: context)
        ticket.storeName = store
        ticket.amount = amount
        ticket.category = category
        ticket.dateMillis = 1_714_000_000_000
        return ticket
    }
    return VStack(spacing: Theme.Spacing.m) {
        TicketRow(ticket: make("Auchan", 79.00, "Alimentation"))
        TicketRow(ticket: make("Leroy Merlin", 130.00, "Maison"))
        TicketRow(
            ticket: make("McDonald's", 12.50, "Restaurant"),
            matchedSnippet: "… menu maxi best of, ticket n° 4821 …"
        )
    }
}
