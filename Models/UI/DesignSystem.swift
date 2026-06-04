import SwiftUI

enum DesignSystem {

    // MARK: - Colors
    static let accent = Theme.primaryBlue

    static let pageBackground = Color(.systemGroupedBackground)
    static let cardBackground = Color(.systemBackground)

    static let shadowColor = Color.black.opacity(
        UITraitCollection.current.userInterfaceStyle == .dark ? 0.3 : 0.05
    )

    // MARK: - Spacing
    static let horizontalPadding: CGFloat = 20
    static let verticalSpacing: CGFloat = 28
    static let innerSpacing: CGFloat = 18

    // MARK: - Radius
    static let smallRadius: CGFloat = 18
    static let mediumRadius: CGFloat = 22
    static let largeRadius: CGFloat = 26

    // MARK: - Shadow
    static let shadowRadius: CGFloat = 12
    static let shadowYOffset: CGFloat = 6

    // MARK: - Gradient
    static var premiumBackground: LinearGradient {
        LinearGradient(
            colors: [
                Theme.primaryBlue.opacity(0.05),
                Color(.systemGroupedBackground)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
