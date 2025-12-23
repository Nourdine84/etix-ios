import SwiftUI
import CoreData

struct SettingsView: View {

    @EnvironmentObject var session: SessionViewModel
    @Environment(\.managedObjectContext) private var context

    @StateObject private var vm: SettingsViewModel

    @State private var showWipeAlert = false
    @AppStorage("app.appearance") private var appearanceRaw: String = AppAppearance.default.rawValue

    init() {
        let ctx = PersistenceController.shared.container.viewContext
        _vm = StateObject(wrappedValue: SettingsViewModel(context: ctx))
    }

    var body: some View {
        NavigationStack {
            Form {

                // MARK: - Compte
                Section(header: Text("Compte")) {
                    Button("Se déconnecter") {
                        Haptic.medium()
                        session.logout()
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
                    Button("Supprimer toutes les données") {
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
                        Text(vm.appVersion)
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Build")
                        Spacer()
                        Text(vm.buildNumber)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Paramètres")
            .alert("Supprimer toutes les données ?", isPresented: $showWipeAlert) {
                Button("Supprimer", role: .destructive) {
                    do {
                        try vm.resetDatabase()
                        Haptic.success()
                    } catch {
                        Haptic.error()
                    }
                }
                Button("Annuler", role: .cancel) {}
            }
        }
    }
}
