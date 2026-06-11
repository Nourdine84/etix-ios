import SwiftUI

/// Carte standard eTix V2 — surface, radius, ombre light-only.
/// Remplace progressivement les `padding + secondarySystemGroupedBackground
/// + cornerRadius` codés à la main (16 fichiers en V1).
struct CardContainer: ViewModifier {

    var radius: CGFloat = Theme.Radius.xl
    var padding: CGFloat = Theme.Spacing.xl
    var shadowEnabled: Bool = true

    @Environment(\.colorScheme) private var scheme

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Background.surface)
            .cornerRadius(radius)
            .shadow(
                color: shadowEnabled && scheme == .light ? Theme.Shadow.cardColor : .clear,
                radius: Theme.Shadow.cardRadius,
                y: Theme.Shadow.cardY
            )
    }
}

extension View {

    /// Applique le style carte du Design System V2.
    func card(
        radius: CGFloat = Theme.Radius.xl,
        padding: CGFloat = Theme.Spacing.xl,
        shadow: Bool = true
    ) -> some View {
        modifier(CardContainer(radius: radius, padding: padding, shadowEnabled: shadow))
    }
}

#Preview("Light") {
    VStack(spacing: 20) {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(text: "Dépenses du mois")
            Text("172,85 €").font(Theme.Typography.displayAmount)
        }
        .card()

        Text("Carte radius l").card(radius: Theme.Radius.l)
    }
    .padding()
    .background(Theme.Background.primary)
}

#Preview("Dark") {
    VStack(spacing: 20) {
        VStack(alignment: .leading, spacing: 8) {
            SectionLabel(text: "Dépenses du mois")
            Text("172,85 €").font(Theme.Typography.displayAmount)
        }
        .card()

        Text("Carte radius l").card(radius: Theme.Radius.l)
    }
    .padding()
    .background(Theme.Background.primary)
    .preferredColorScheme(.dark)
}
