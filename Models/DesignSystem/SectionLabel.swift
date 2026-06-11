import SwiftUI

/// Label de section uppercase — pattern overline des maquettes V2.
/// Remplace progressivement les `Text(...).font(.caption2).tracking(1)`
/// dupliqués dans les écrans V1.
struct SectionLabel: View {

    let text: String

    var body: some View {
        Text(text)
            .font(Theme.Typography.overline)
            .tracking(1.5)
            .textCase(.uppercase)
            .foregroundColor(.secondary)
    }
}

#Preview("Light") {
    VStack(alignment: .leading, spacing: 16) {
        SectionLabel(text: "Dépenses du mois")
        SectionLabel(text: "TENDANCE 6 MOIS")
    }
    .padding()
    .background(Theme.Background.primary)
}

#Preview("Dark") {
    VStack(alignment: .leading, spacing: 16) {
        SectionLabel(text: "Dépenses du mois")
        SectionLabel(text: "TENDANCE 6 MOIS")
    }
    .padding()
    .background(Theme.Background.primary)
    .preferredColorScheme(.dark)
}
