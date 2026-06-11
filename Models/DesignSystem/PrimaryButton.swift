import SwiftUI

/// CTA principal eTix V2 — hauteur 52, radius 14, fond bleu, texte blanc.
/// Conserve le feedback haptique et l'animation spring hérités d'eTixButton.
/// Remplace eTixButton au fil des redesigns (Splash V2, Onboarding V2, Home V3).
struct PrimaryButton: View {

    let title: String
    var icon: String? = nil
    let action: () -> Void

    @Environment(\.colorScheme) private var scheme

    var body: some View {
        Button {
            Haptic.light()
            withAnimation(.spring(response: 0.3)) {
                action()
            }
        } label: {
            HStack(spacing: Theme.Spacing.s) {
                if let icon {
                    Image(systemName: icon)
                        .font(.headline)
                }
                Text(title)
                    .font(Theme.Typography.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Theme.primaryBlue)
            .cornerRadius(Theme.Radius.button)
            .shadow(
                color: .black.opacity(scheme == .dark ? 0.28 : 0.15),
                radius: 6,
                y: 3
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview("Light") {
    VStack(spacing: 20) {
        PrimaryButton(title: "Scanner le ticket", icon: "camera.viewfinder") {}
        PrimaryButton(title: "Envoyer le lien") {}
    }
    .padding()
    .background(Theme.Background.primary)
}

#Preview("Dark") {
    VStack(spacing: 20) {
        PrimaryButton(title: "Scanner le ticket", icon: "camera.viewfinder") {}
        PrimaryButton(title: "Envoyer le lien") {}
    }
    .padding()
    .background(Theme.Background.primary)
    .preferredColorScheme(.dark)
}
