import SwiftUI

/// Atmosphère d'ambiance V2 — glow radial central, halo d'horizon bas,
/// micro-étoiles statiques en dark. Extraite du Splash V2 (rendu identique
/// à intensity 1.0) maintenant qu'elle a deux consommateurs réels :
/// SplashView et OnboardingView.
/// Règle produit : l'atmosphère reste discrète, le contenu domine.
struct AmbientBackground: View {

    /// 1.0 = réglage Splash. L'Onboarding utilise une valeur moindre.
    var intensity: Double = 1.0
    /// Décalage vertical du glow central (le Splash le centre sur le badge).
    var glowOffsetY: CGFloat = -40

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        ZStack {
            // Glow radial central
            RadialGradient(
                colors: [
                    scheme == .dark
                        ? Theme.primaryBlue.opacity(0.10 * intensity)
                        : Color.white.opacity(0.60 * intensity),
                    .clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 220
            )
            .offset(y: glowOffsetY)

            // Halo d'horizon bas
            Ellipse()
                .fill(Theme.primaryBlue.opacity((scheme == .dark ? 0.16 : 0.08) * intensity))
                .frame(width: 500, height: 120)
                .blur(radius: 50)
                .offset(y: 420)

            // Micro-étoiles statiques — dark uniquement
            if scheme == .dark {
                stars
            }
        }
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    /// Points statiques seedés — positions fixes, aucune animation.
    private var stars: some View {
        Canvas { context, canvasSize in
            var seed: UInt32 = 9
            func next() -> CGFloat {
                seed = seed &* 1_664_525 &+ 1_013_904_223
                return CGFloat(seed % 1000) / 1000
            }
            for _ in 0..<14 {
                let x = next() * canvasSize.width
                let y = next() * canvasSize.height
                let radius = 0.6 + next() * 1.2
                let alpha = (0.05 + next() * 0.10) * intensity
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: radius * 2, height: radius * 2)),
                    with: .color(.white.opacity(alpha))
                )
            }
        }
    }
}

#Preview("Light") {
    ZStack {
        Theme.Background.primary.ignoresSafeArea()
        AmbientBackground()
        EtixBadge(size: 120).offset(y: -40)
    }
}

#Preview("Dark") {
    ZStack {
        Theme.Background.primary.ignoresSafeArea()
        AmbientBackground()
        EtixBadge(size: 120).offset(y: -40)
    }
    .preferredColorScheme(.dark)
}
