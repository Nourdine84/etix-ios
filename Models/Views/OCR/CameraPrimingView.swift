import SwiftUI

/// Écran de priming caméra — premium, conforme à la maquette V2.
///
/// Il **explique** l'usage de la caméra et **rassure** l'utilisateur, puis
/// délègue à `onAllow` le déclenchement de la **permission système iOS**.
/// Il ne remplace pas la boîte de dialogue native : il la précède.
/// Affiché uniquement au premier accès (permission `notDetermined`).
struct CameraPrimingView: View {

    let onAllow: () -> Void
    let onRefuse: () -> Void

    var body: some View {
        ZStack {
            Theme.Background.primary
                .ignoresSafeArea()

            VStack(spacing: Theme.Spacing.xl) {
                Spacer(minLength: 0)

                VStack(spacing: Theme.Spacing.m) {
                    Text("Autoriser l'accès à ton appareil photo")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)

                    Text("Tu pourras scanner tes tickets pour en extraire automatiquement les informations. Aucune image n'est envoyée sur un serveur.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }

                Spacer(minLength: 0)

                Image(systemName: "camera.fill")
                    .font(.system(size: 68))
                    .foregroundColor(Theme.primaryBlue)

                Spacer(minLength: 0)

                HStack(spacing: Theme.Spacing.m) {
                    Button {
                        onRefuse()
                    } label: {
                        Text("Refuser")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Theme.Background.surface)
                            .cornerRadius(Theme.Radius.button)
                    }
                    .buttonStyle(.plain)

                    Button {
                        onAllow()
                    } label: {
                        Text("Autoriser")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Theme.primaryBlue)
                            .cornerRadius(Theme.Radius.button)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.Spacing.xxl)
            .padding(.vertical, Theme.Spacing.section)
        }
    }
}

#Preview("Light") {
    CameraPrimingView(onAllow: {}, onRefuse: {})
}

#Preview("Dark") {
    CameraPrimingView(onAllow: {}, onRefuse: {})
        .preferredColorScheme(.dark)
}
