import SwiftUI

struct PremiumCardModifier: ViewModifier {

    func body(content: Content) -> some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.mediumRadius)
                    .fill(DesignSystem.cardBackground)
                    .shadow(
                        color: DesignSystem.shadowColor,
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
