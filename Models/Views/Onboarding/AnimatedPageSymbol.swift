import SwiftUI

struct AnimatedPageSymbol: View {
    let systemImage: String
    let accent: Color
    let index: Int

    @State private var rotation: Double = 0
    @State private var bounce: CGFloat = 1
    @State private var glow: Double = 0.12
    @State private var offsetY: CGFloat = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(accent.opacity(glow))
                .frame(width: 230, height: 230)
                .blur(radius: 14)

            Image(systemName: systemImage)
                .font(.system(size: 92, weight: .bold))
                .foregroundStyle(accent)
                .rotationEffect(.degrees(rotation))
                .scaleEffect(bounce)
                .offset(y: offsetY)
                .onAppear { startAnimations() }
        }
        .padding(.top, 8)
    }

    private func startAnimations() {
        switch systemImage {

        case "ticket.fill":
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                rotation = 8
            }
            withAnimation(.easeInOut(duration: 1.4).delay(0.2).repeatForever(autoreverses: true)) {
                glow = 0.25
            }

        case "plus.circle.fill":
            withAnimation(.spring(response: 1.0, dampingFraction: 0.45).repeatForever(autoreverses: true)) {
                bounce = 1.1
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                glow = 0.20
            }

        case "chart.bar.fill":
            withAnimation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true)) {
                offsetY = -6
            }
            withAnimation(.easeInOut(duration: 1.6).delay(0.1).repeatForever(autoreverses: true)) {
                glow = 0.18
            }

        default:
            withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
                rotation = 4
                glow = 0.18
            }
        }
    }
}
