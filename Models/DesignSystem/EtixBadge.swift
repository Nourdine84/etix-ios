import SwiftUI

/// Badge "e" circulaire officiel eTix — reconstruction vectorielle de
/// l'identité des maquettes V2 (header de Home, Stats, Support, OCR…).
/// Vectoriel : toutes tailles, light/dark, sans assets @2x/@3x.
/// Si un export PNG officiel arrive un jour, seul l'intérieur de ce
/// composant change — son API reste stable.
struct EtixBadge: View {

    var size: CGFloat = 120

    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 64/255, green: 156/255, blue: 255/255),
                            Theme.primaryBlue
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Text("e")
                .font(.system(size: size * 0.58, weight: .heavy, design: .rounded))
                .foregroundColor(.white)
                .offset(y: -size * 0.02)
        }
        .overlay(
            Circle()
                .strokeBorder(Color.white.opacity(0.35), lineWidth: size * 0.02)
        )
        .frame(width: size, height: size)
        .shadow(color: Theme.primaryBlue.opacity(0.30), radius: size * 0.12, y: size * 0.05)
    }
}

#Preview("Tailles — Light") {
    VStack(spacing: 32) {
        EtixBadge(size: 120)
        HStack(spacing: 24) {
            EtixBadge(size: 56)
            EtixBadge(size: 40)
            EtixBadge(size: 28)
        }
    }
    .padding(40)
    .background(Theme.Background.primary)
}

#Preview("Dark") {
    EtixBadge(size: 120)
        .padding(60)
        .background(Theme.Background.primary)
        .preferredColorScheme(.dark)
}
