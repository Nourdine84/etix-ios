import SwiftUI

struct HighlightModifier: ViewModifier {

    let isHighlighted: Bool

    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(
                isHighlighted
                ? Color(Theme.primaryBlue).opacity(0.08)
                : Color.clear
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(
                        isHighlighted
                        ? Color(Theme.primaryBlue).opacity(0.35)
                        : Color.clear,
                        lineWidth: 1
                    )
            )
            .cornerRadius(14)
    }
}
