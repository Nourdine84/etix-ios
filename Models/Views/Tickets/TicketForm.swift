import SwiftUI

/// Niveau de confiance affiché à côté d'un champ.
/// **Type UI pur** : aucune connaissance de l'OCR ni du scanner. Le mapping
/// depuis la couche métier (`OCRConfidence`) se fait à l'extérieur, côté
/// AddTicket. En édition, aucun badge n'est passé (tout `nil`).
enum FieldConfidence {
    case verified   // « Vérifié »   — vert discret
    case toVerify   // « À vérifier » — ambre
}

/// Formulaire de ticket partagé entre la saisie manuelle (AddTicket) et
/// l'édition (TicketEdit) — Design System V2.
///
/// Il ne reçoit que des **données à afficher et éditer** : bindings de champs,
/// niveaux de confiance déjà mappés, et une action d'ouverture du sélecteur de
/// catégorie. Aucune logique métier, aucune dépendance OCR/scanner.
struct TicketForm: View {

    @Binding var storeName: String
    @Binding var amount: String
    @Binding var date: Date
    @Binding var category: String
    @Binding var description: String

    var storeConfidence: FieldConfidence? = nil
    var amountConfidence: FieldConfidence? = nil
    var dateConfidence: FieldConfidence? = nil
    var categorySuggested: Bool = false
    var amountInvalid: Bool = false

    let onPickCategory: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.l) {

            field(label: "Magasin", confidence: storeConfidence) {
                TextField("Nom du magasin", text: $storeName)
                    .textInputAutocapitalization(.words)
            }

            Divider()

            field(label: "Montant", confidence: amountConfidence) {
                TextField("0,00 €", text: $amount)
                    .keyboardType(.decimalPad)
                    .foregroundColor(amountInvalid ? .red : .primary)
            }

            Divider()

            field(label: "Date", confidence: dateConfidence) {
                DatePicker("", selection: $date, displayedComponents: .date)
                    .labelsHidden()
            }

            Divider()

            categoryRow

            Divider()

            field(label: "Description", confidence: nil) {
                TextField("Optionnel", text: $description, axis: .vertical)
                    .lineLimit(1...4)
            }
        }
        .card()
    }

    // MARK: - Ligne générique

    @ViewBuilder
    private func field<Content: View>(
        label: String,
        confidence: FieldConfidence?,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            HStack {
                SectionLabel(text: label)
                Spacer()
                if let confidence {
                    confidenceBadge(confidence)
                }
            }
            content()
                .font(Theme.Typography.body)
        }
    }

    // MARK: - Catégorie

    private var categoryRow: some View {
        Button(action: onPickCategory) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                HStack {
                    SectionLabel(text: "Catégorie")
                    Spacer()
                    if categorySuggested {
                        HStack(spacing: 3) {
                            Image(systemName: "wand.and.stars")
                                .font(.caption2)
                            Text("Suggéré par l'OCR")
                                .font(.caption2)
                        }
                        .foregroundColor(Theme.primaryBlue.opacity(0.8))
                    }
                }
                HStack(spacing: Theme.Spacing.m) {
                    if !category.isEmpty {
                        CategoryIconView(category: category, size: 28)
                    }
                    Text(category.isEmpty ? "Choisir une catégorie" : category)
                        .font(Theme.Typography.body)
                        .foregroundColor(category.isEmpty ? .secondary : .primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Badge de confiance

    private func confidenceBadge(_ confidence: FieldConfidence) -> some View {
        let text: String
        let color: Color
        let icon: String
        switch confidence {
        case .verified:
            text = "Vérifié"; color = .green; icon = "checkmark.seal.fill"
        case .toVerify:
            text = "À vérifier"; color = .orange; icon = "exclamationmark.triangle.fill"
        }
        return HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 9))
            Text(text)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(color)
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
}

#Preview("Édition (sans badges)") {
    TicketFormPreview(withConfidence: false)
}

#Preview("Après scan (badges)") {
    TicketFormPreview(withConfidence: true)
}

private struct TicketFormPreview: View {
    let withConfidence: Bool
    @State private var store = "Carrefour City"
    @State private var amount = "20,00"
    @State private var date = Date()
    @State private var category = "Alimentation"
    @State private var desc = ""

    var body: some View {
        ScrollView {
            TicketForm(
                storeName: $store,
                amount: $amount,
                date: $date,
                category: $category,
                description: $desc,
                storeConfidence: withConfidence ? .verified : nil,
                amountConfidence: withConfidence ? .toVerify : nil,
                dateConfidence: withConfidence ? .verified : nil,
                categorySuggested: withConfidence,
                onPickCategory: {}
            )
            .padding(Theme.Spacing.xxl)
        }
        .background(Theme.Background.primary)
    }
}
