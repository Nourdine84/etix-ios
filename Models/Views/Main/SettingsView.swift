import SwiftUI

struct SettingsView: View {

    @EnvironmentObject var session: SessionViewModel

    @State private var showWipeAlert = false
    @AppStorage("app.appearance") private var appearanceRaw: String = AppAppearance.default.rawValue

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Compte
                Section(header: Text("Compte")) {

                    Button {
                        Haptic.medium()
                        session.logout()
                    } label: {
                        Text("Se déconnecter")
                    }
                    .foregroundColor(.blue)
                }

                // MARK: - Données
                Section(header: Text("Données")) {

                    Button {
                        Haptic.warning()
                        showWipeAlert = true
                    } label: {
                        Text("Réinitialiser les tickets")
                    }
                    .foregroundColor(.red)

                    // ⏳ FUTUR – Backup / Export cloud
                    HStack {
                        Text("Sauvegarde & restauration")
                        Spacer()
                        Text("Bientôt")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .disabled(true)
                }

                // MARK: - Apparence
                Section(header: Text("Apparence")) {

                    Picker("Thème", selection: $appearanceRaw) {
                        Text("Système").tag(AppAppearance.system.rawValue)
                        Text("Clair").tag(AppAppearance.light.rawValue)
                        Text("Sombre").tag(AppAppearance.dark.rawValue)
                    }

                    // ⏳ FUTUR – Animations / UI options
                    HStack {
                        Text("Animations")
                        Spacer()
                        Text("Bientôt")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .disabled(true)
                }

                // MARK: - Fonctionnalités
                Section(header: Text("Fonctionnalités")) {

                    // ⏳ FUTUR – OCR
                    HStack {
                        Text("Scanner OCR")
                        Spacer()
                        Text("Bientôt")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .disabled(true)

                    // ⏳ FUTUR – Notifications
                    HStack {
                        Text("Notifications")
                        Spacer()
                        Text("Bientôt")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .disabled(true)
                }

                // MARK: - À propos
                Section(header: Text("À propos")) {

                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }

                    // ⏳ FUTUR – Mentions légales
                    HStack {
                        Text("Mentions légales")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .disabled(true)

                    // ⏳ FUTUR – Politique de confidentialité
                    HStack {
                        Text("Confidentialité")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .disabled(true)
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

    // MARK: - App Version
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}
