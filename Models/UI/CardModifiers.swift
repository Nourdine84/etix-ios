import SwiftUI

// MARK: - Primary Card

struct CardStyleModifier: ViewModifier {

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(22)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.largeRadius)
                    .fill(DesignSystem.surfacePrimary)
                    .shadow(
                        color: DesignSystem.shadowColor(for: colorScheme),
                        radius: DesignSystem.shadowRadius,
                        x: 0,
                        y: DesignSystem.shadowYOffset
                    )
            )
    }
}

// MARK: - Small Card

struct SmallCardStyleModifier: ViewModifier {

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.smallRadius)
                    .fill(DesignSystem.surfaceSecondary)
                    .shadow(
                        color: DesignSystem.shadowColor(for: colorScheme),
                        radius: DesignSystem.shadowRadius * 0.6,
                        x: 0,
                        y: DesignSystem.shadowYOffset * 0.6
                    )
            )
    }
}

// MARK: - Extensions

extension View {

    func cardStyle() -> some View {
        self.modifier(CardStyleModifier())
    }

    func smallCardStyle() -> some View {
        self.modifier(SmallCardStyleModifier())
    }
}
