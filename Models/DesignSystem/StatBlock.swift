import SwiftUI

/// Bloc statistique label + valeur — unifie les trois implémentations V1
/// (statCard de StoreDetailView, kpiBlock de MonthlyReportView, stats Home).
struct StatBlock: View {

    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            SectionLabel(text: label)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview("Grille 2×2") {
    VStack(spacing: 16) {
        HStack(spacing: 16) {
            StatBlock(label: "Panier moyen", value: "23,40 €").card(radius: Theme.Radius.l, padding: Theme.Spacing.l)
            StatBlock(label: "Tickets", value: "12").card(radius: Theme.Radius.l, padding: Theme.Spacing.l)
        }
        HStack(spacing: 16) {
            StatBlock(label: "Dernière visite", value: "19 mars 2024").card(radius: Theme.Radius.l, padding: Theme.Spacing.l)
            StatBlock(label: "Fréquence", value: "tous les 6 j").card(radius: Theme.Radius.l, padding: Theme.Spacing.l)
        }
    }
    .padding()
    .background(Theme.Background.primary)
}
