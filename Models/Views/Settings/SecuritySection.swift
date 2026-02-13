import SwiftUI

struct SecuritySection: View {

    @AppStorage("app.biometricEnabled")
    private var biometricEnabled: Bool = false

    var body: some View {
        SettingsCard(title: "Sécurité", icon: "lock.fill") {

            Toggle(isOn: $biometricEnabled) {
                Label("Activer Face ID / Touch ID", systemImage: "faceid")
            }

            Divider()

            Label("Les données restent stockées localement", systemImage: "shield.fill")
                .foregroundColor(.secondary)
                .font(.caption)
        }
    }
}
