import SwiftUI

struct PremiumCardModifier: ViewModifier {

    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.mediumRadius)
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

extension View {
    func premiumCard() -> some View {
        modifier(PremiumCardModifier())
    }
}
