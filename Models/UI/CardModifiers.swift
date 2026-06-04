import SwiftUI

// MARK: - Primary Card

struct CardStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(22)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.largeRadius)
                    .fill(DesignSystem.cardBackground)
                    .shadow(
                        color: DesignSystem.shadowColor,
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
    }
}

// MARK: - Small Card

struct SmallCardStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.smallRadius)
                    .fill(DesignSystem.cardBackground)
                    .shadow(
                        color: DesignSystem.shadowColor,
                        radius: 6,
                        x: 0,
                        y: 3
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
