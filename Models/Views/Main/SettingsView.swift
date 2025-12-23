import SwiftUI

struct SettingsView: View {

    // MARK: - Environment
    @EnvironmentObject var session: SessionViewModel

    // MARK: - App storage
    @AppStorage("app.appearance")
    private var appearanceRaw: String = AppAppearance.system.rawValue

    // MARK: - UI State
    @State private var showLogoutAlert = false
    @State private var showWipeAlert = false

    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Compte
                Section(header: Text("Compte")) {
                    Button {
                        Haptic.medium()
                        showLogoutAlert = true
                    } label: {
                        Text("Se déconnecter")
                    }
                    .foregroundColor(.blue)
                }

                // MARK: - Apparence
                Section(header: Text("Apparence")) {
                    Picker("Thème", selection: $appearanceRaw) {
                        Text("Système").tag(AppAppearance.system.rawValue)
                        Text("Clair").tag(AppAppearance.light.rawValue)
                        Text("Sombre").tag(AppAppearance.dark.rawValue)
                    }
                }

                // MARK: - Données
                Section(header: Text("Données")) {
                    Button {
                        Haptic.warning()
                        showWipeAlert = true
                    } label: {
                        Text("Supprimer toutes les données")
                    }
                    .foregroundColor(.red)
                }

                // MARK: - À propos
                Section(header: Text("À propos")) {
                    infoRow(title: "Version", value: appVersion)
                    infoRow(title: "Build", value: appBuild)
                }
            }
            .navigationTitle("Paramètres")
        }

        // MARK: - Logout Alert
        .alert("Se déconnecter ?", isPresented: $showLogoutAlert) {
            Button("Se déconnecter", role: .destructive) {
                session.logout()
            }
            Button("Annuler", role: .cancel) {}
        }

        // MARK: - Wipe Data Alert
        .alert("Supprimer toutes les données ?", isPresented: $showWipeAlert) {
            Button("Supprimer", role: .destructive) {
                PersistenceController.shared.wipeDatabase()
            }
            Button("Annuler", role: .cancel) {}
        }
    }

    // MARK: - Helpers
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}
