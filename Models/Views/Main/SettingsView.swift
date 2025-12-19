import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var session: SessionViewModel
    @State private var showWipeAlert = false
    @AppStorage("app.appearance") private var appearanceRaw: String = AppAppearance.default.rawValue

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Section Compte
                Section(header: Text("Compte")) {
                    Button("Se déconnecter") {
                        Haptic.medium()
                        session.logout()
                    }
                    .foregroundColor(.blue)
                }

                // MARK: - Section Apparence
                Section(header: Text("Apparence")) {
                    Picker("Thème", selection: $appearanceRaw) {
                        Text("Système").tag(AppAppearance.system.rawValue)
                        Text("Clair").tag(AppAppearance.light.rawValue)
                        Text("Sombre").tag(AppAppearance.dark.rawValue)
                    }
                }

                // MARK: - Section Données
                Section(header: Text("Données")) {
                    Button("Réinitialiser les tickets") {
                        Haptic.warning()
                        showWipeAlert = true
                    }
                    .foregroundColor(.red)
                }

                // MARK: - À propos
                Section(header: Text("À propos")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Paramètres")
            .alert("Supprimer tous les tickets ?", isPresented: $showWipeAlert) {
                Button("Supprimer", role: .destructive) {
                    PersistenceController.shared.wipeDatabase()
                }
                Button("Annuler", role: .cancel) {}
            }
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
