import SwiftUI

extension View {
    func shimmer() -> some View {
        self
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        Color.white.opacity(0.4),
                        .clear
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(15))
                .offset(x: -200)
                .animation(
                    .linear(duration: 1.2).repeatForever(autoreverses: false),
                    value: UUID()
                )
            )
            .mask(self)
    }
}
