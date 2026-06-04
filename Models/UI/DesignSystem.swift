import SwiftUI

enum DesignSystem {

    static let accent = Theme.primaryBlue

    // MARK: - Surfaces

    static var pageBackground: Color {
        Color(.systemGroupedBackground)
    }

    static var surfacePrimary: Color {
        Color(.systemBackground)
    }

    static var surfaceSecondary: Color {
        Color(.secondarySystemBackground)
    }

    static var surfaceTertiary: Color {
        Color(.tertiarySystemBackground)
    }

    // MARK: - Shadow

    static func shadowColor(for scheme: ColorScheme) -> Color {
        scheme == .dark
        ? Color.black.opacity(0.45)
        : Color.black.opacity(0.08)
    }

    static let shadowRadius: CGFloat = 14
    static let shadowYOffset: CGFloat = 6

    // MARK: - Spacing

    static let horizontalPadding: CGFloat = 20
    static let verticalSpacing: CGFloat = 36
    static let innerSpacing: CGFloat = 20

    // MARK: - Radius

    static let smallRadius: CGFloat = 18
    static let mediumRadius: CGFloat = 22
    static let largeRadius: CGFloat = 28

    // MARK: - Premium Background (Depth Upgrade)

    static func premiumBackground(for scheme: ColorScheme) -> LinearGradient {

        if scheme == .dark {
            return LinearGradient(
                colors: [
                    Theme.primaryBlue.opacity(0.25),
                    Color(.systemGroupedBackground),
                    Color(.systemGroupedBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            return LinearGradient(
                colors: [
                    Theme.primaryBlue.opacity(0.10),
                    Color(.systemGroupedBackground),
                    Color(.systemGroupedBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}
