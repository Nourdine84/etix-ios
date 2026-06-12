import SwiftUI

/// Splash V2 — fond lavande/navy (Theme.Background.primary), badge "e"
/// vectoriel dominant, wordmark .primary, atmosphère volontairement sobre.
/// Durée : 1.4s + 0.4s de fondu de sortie. Respecte Reduce Motion.
struct SplashView: View {

    @EnvironmentObject var session: SessionViewModel

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var badgeOpacity: Double = 0
    @State private var badgeScale: CGFloat = 0.92
    @State private var wordmarkOpacity: Double = 0
    @State private var wordmarkOffset: CGFloat = 8
    @State private var accentsOpacity: Double = 0

    var body: some View {
        ZStack {
            Theme.Background.primary
                .ignoresSafeArea()

            // Atmosphère — sous le badge, volontairement discrète :
            // le badge doit rester l'unique point focal.
            AmbientBackground()
                .opacity(accentsOpacity)

            // Héros : badge + wordmark
            VStack(spacing: 24) {
                ZStack {
                    EtixBadge(size: 120)
                        .scaleEffect(badgeScale)
                        .opacity(badgeOpacity)

                    sparkles
                        .opacity(accentsOpacity)
                }

                Text("eTix")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .opacity(wordmarkOpacity)
                    .offset(y: wordmarkOffset)
            }
            .offset(y: -40)
        }
        .onAppear(perform: startAnimations)
        .task {
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            withAnimation(.easeInOut(duration: 0.4)) {
                session.decideNextAfterSplash()
            }
        }
    }

    /// 3 étincelles max, très discrètes — règle produit validée.
    private var sparkles: some View {
        ZStack {
            Image(systemName: "sparkle")
                .font(.system(size: 12))
                .foregroundColor(.yellow.opacity(0.75))
                .offset(x: -82, y: -38)

            Image(systemName: "sparkle")
                .font(.system(size: 8))
                .foregroundColor(Theme.primaryBlue.opacity(0.55))
                .offset(x: 86, y: 44)

            Circle()
                .fill(Theme.primaryBlue.opacity(0.35))
                .frame(width: 5, height: 5)
                .offset(x: 64, y: -66)
        }
    }

    // MARK: - Animations

    private func startAnimations() {
        if reduceMotion {
            // Fondus simples — ni scale ni translation
            badgeScale = 1.0
            wordmarkOffset = 0
            withAnimation(.easeInOut(duration: 0.5)) {
                badgeOpacity = 1
                wordmarkOpacity = 1
                accentsOpacity = 1
            }
            return
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            badgeOpacity = 1
            badgeScale = 1.0
        }
        withAnimation(.easeOut(duration: 0.45).delay(0.15)) {
            wordmarkOpacity = 1
            wordmarkOffset = 0
        }
        withAnimation(.easeIn(duration: 0.4).delay(0.3)) {
            accentsOpacity = 1
        }
    }
}

#Preview("Light") {
    SplashView()
        .environmentObject(SessionViewModel())
}

#Preview("Dark") {
    SplashView()
        .environmentObject(SessionViewModel())
        .preferredColorScheme(.dark)
}
